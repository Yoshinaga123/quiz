package main

import (
	"database/sql"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"runtime"
	"runtime/debug"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	_ "github.com/lib/pq"
	"github.com/shirou/gopsutil/mem"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

type server struct {
	db            *sql.DB
	adminUser     string
	adminPassword string
	jwtSecret     []byte
}

type rowScanner interface {
	Scan(dest ...any) error
}

type errorResponse struct {
	Error string `json:"error"`
}

type healthResponse struct {
	Status string `json:"status"`
}

type countResponse struct {
	Count int `json:"count"`
}

type loginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type loginResponse struct {
	Token string `json:"token"`
}

type quiz struct {
	ID                 int64     `json:"id"`
	Section            string    `json:"section"`
	Title              string    `json:"title"`
	Question           string    `json:"question"`
	Code               *string   `json:"code,omitempty"`
	Options            []string  `json:"options"`
	CorrectAnswerIndex int       `json:"correctAnswerIndex"`
	Explanation        string    `json:"explanation"`
	Source             string    `json:"source"`
	Status             string    `json:"status"`
	PushEnabled        bool      `json:"pushEnabled"`
	CreatedAt          time.Time `json:"createdAt"`
	UpdatedAt          time.Time `json:"updatedAt"`
}

type quizListResponse struct {
	Items      []quiz `json:"items"`
	Total      int    `json:"total"`
	Page       int    `json:"page"`
	PerPage    int    `json:"perPage"`
	TotalPages int    `json:"totalPages"`
}

type quizPayload struct {
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               string   `json:"code"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
	Status             string   `json:"status"`
	PushEnabled        bool     `json:"pushEnabled"`
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func initDB() (*sql.DB, error) {
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "password")
	name := getEnv("DB_NAME", "counter")

	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host,
		port,
		user,
		password,
		name,
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	if err := runMigrations(db); err != nil {
		return nil, fmt.Errorf("migration: %w", err)
	}

	return db, nil
}

func runMigrations(db *sql.DB) error {
	srcDriver, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		return err
	}

	dbDriver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		return err
	}

	m, err := migrate.NewWithInstance("iofs", srcDriver, "postgres", dbDriver)
	if err != nil {
		return err
	}

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}

	return nil
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if payload == nil {
		return
	}

	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("encode response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, errorResponse{Error: message})
}

func decodeJSON(r *http.Request, dst any) error {
	defer r.Body.Close()

	decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(dst); err != nil {
		return err
	}

	var extra json.RawMessage
	if err := decoder.Decode(&extra); err != io.EOF {
		return errors.New("request body must contain a single JSON object")
	}

	return nil
}

func normalizeQuizPayload(payload *quizPayload) error {
	payload.Section = strings.TrimSpace(payload.Section)
	payload.Title = strings.TrimSpace(payload.Title)
	payload.Question = strings.TrimSpace(payload.Question)
	payload.Code = strings.TrimSpace(payload.Code)
	payload.Explanation = strings.TrimSpace(payload.Explanation)
	payload.Source = strings.TrimSpace(payload.Source)
	payload.Status = strings.TrimSpace(payload.Status)

	if payload.Section == "" {
		return errors.New("section is required")
	}
	if payload.Title == "" {
		return errors.New("title is required")
	}
	if payload.Question == "" {
		return errors.New("question is required")
	}
	if payload.Explanation == "" {
		return errors.New("explanation is required")
	}
	if payload.Source == "" {
		return errors.New("source is required")
	}
	if payload.Status != "published" && payload.Status != "unpublished" {
		return errors.New("status must be published or unpublished")
	}

	if len(payload.Options) < 2 {
		return errors.New("at least two options are required")
	}

	for index := range payload.Options {
		payload.Options[index] = strings.TrimSpace(payload.Options[index])
		if payload.Options[index] == "" {
			return fmt.Errorf("option %d is required", index+1)
		}
	}

	if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
		return errors.New("correctAnswerIndex is out of range")
	}

	return nil
}

func scanQuiz(scanner rowScanner) (quiz, error) {
	var item quiz
	var code sql.NullString
	var optionsJSON []byte

	err := scanner.Scan(
		&item.ID,
		&item.Section,
		&item.Title,
		&item.Question,
		&code,
		&optionsJSON,
		&item.CorrectAnswerIndex,
		&item.Explanation,
		&item.Source,
		&item.Status,
		&item.PushEnabled,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		return quiz{}, err
	}

	if code.Valid {
		item.Code = &code.String
	}

	if err := json.Unmarshal(optionsJSON, &item.Options); err != nil {
		return quiz{}, err
	}

	return item, nil
}

func parseID(raw string) (int64, error) {
	id, err := strconv.ParseInt(raw, 10, 64)
	if err != nil || id <= 0 {
		return 0, errors.New("invalid quiz id")
	}
	return id, nil
}

func formatBytes(bytes uint64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}

	div, exp := uint64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}

	return fmt.Sprintf("%.2f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}

func logMemoryStats() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Printf("Alloc（ヒープ使用中）: %s\n", formatBytes(stats.Alloc))
	fmt.Printf("TotalAlloc（累計）: %s\n", formatBytes(stats.TotalAlloc))
	fmt.Printf("Sys（OS取得合計）: %s\n", formatBytes(stats.Sys))
	fmt.Printf("NumGC（GCサイクル数）: %d\n", stats.NumGC)
	fmt.Printf("HeapAlloc: %s\n", formatBytes(stats.HeapAlloc))
	fmt.Printf("HeapSys: %s\n", formatBytes(stats.HeapSys))
	fmt.Printf("HeapIdle: %s\n", formatBytes(stats.HeapIdle))
	fmt.Printf("HeapInuse: %s\n", formatBytes(stats.HeapInuse))
	fmt.Printf("HeapReleased: %s\n", formatBytes(stats.HeapReleased))
	fmt.Printf("HeapObjects: %d\n", stats.HeapObjects)
}

func analyzeNonHeapMemory() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== Stack and System Memory ===")
	fmt.Printf("StackInuse: %s\n", formatBytes(stats.StackInuse))
	fmt.Printf("StackSys: %s\n", formatBytes(stats.StackSys))
	fmt.Printf("MSpanInuse: %s\n", formatBytes(stats.MSpanInuse))
	fmt.Printf("MSpanSys: %s\n", formatBytes(stats.MSpanSys))
	fmt.Printf("MCacheInuse: %s\n", formatBytes(stats.MCacheInuse))
	fmt.Printf("MCacheSys: %s\n", formatBytes(stats.MCacheSys))
	fmt.Printf("BuckHashSys: %s\n", formatBytes(stats.BuckHashSys))
	fmt.Printf("GCSys: %s\n", formatBytes(stats.GCSys))
	fmt.Printf("OtherSys: %s\n", formatBytes(stats.OtherSys))

	numGoroutines := runtime.NumGoroutine()
	if numGoroutines > 0 {
		avgStack := stats.StackInuse / uint64(numGoroutines)
		fmt.Printf("Average Stack per Goroutine: %s\n", formatBytes(avgStack))
	}
}

func analyzeGC() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== Garbage Collection Statistics ===")
	fmt.Printf("Completed GC Cycles: %d\n", stats.NumGC)
	fmt.Printf("Forced GC Cycles: %d\n", stats.NumForcedGC)

	if stats.LastGC > 0 {
		lastGCTime := time.Unix(0, int64(stats.LastGC))
		fmt.Printf("Last GC: %s\n", lastGCTime.Format(time.RFC3339))
		fmt.Printf("Time Since Last GC: %s\n", time.Since(lastGCTime))
	}

	fmt.Printf("Total GC Pause Time: %s\n", time.Duration(stats.PauseTotalNs))

	if stats.NumGC > 0 {
		avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
		fmt.Printf("Average GC Pause: %s\n", avgPause)
	}

	fmt.Printf("GC CPU Fraction: %.4f%%\n", stats.GCCPUFraction*100)
	fmt.Printf("Next GC Target: %s\n", formatBytes(stats.NextGC))
	fmt.Printf("Total Mallocs: %d\n", stats.Mallocs)
	fmt.Printf("Total Frees: %d\n", stats.Frees)
	fmt.Printf("Live Objects (Mallocs - Frees): %d\n", stats.Mallocs-stats.Frees)
}

func analyzeGCPauses() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== GC Pause Analysis ===")

	if stats.NumGC == 0 {
		fmt.Println("No GC cycles completed yet")
		return
	}

	var pauses []time.Duration
	numPauses := int(stats.NumGC)
	if numPauses > 256 {
		numPauses = 256
	}

	for i := 0; i < numPauses; i++ {
		idx := int((stats.NumGC - uint32(i) - 1 + 256) % 256)
		pause := time.Duration(stats.PauseNs[idx])
		if pause > 0 {
			pauses = append(pauses, pause)
		}
	}

	if len(pauses) == 0 {
		fmt.Println("No pause data available")
		return
	}

	sort.Slice(pauses, func(i, j int) bool {
		return pauses[i] < pauses[j]
	})

	var total time.Duration
	for _, pause := range pauses {
		total += pause
	}

	fmt.Printf("Number of Recorded Pauses: %d\n", len(pauses))
	fmt.Printf("Min Pause: %s\n", pauses[0])
	fmt.Printf("Max Pause: %s\n", pauses[len(pauses)-1])
	fmt.Printf("Avg Pause: %s\n", total/time.Duration(len(pauses)))

	p50 := pauses[len(pauses)*50/100]
	p90 := pauses[len(pauses)*90/100]
	p99 := pauses[len(pauses)*99/100]

	fmt.Printf("P50 Pause: %s\n", p50)
	fmt.Printf("P90 Pause: %s\n", p90)
	fmt.Printf("P99 Pause: %s\n", p99)

	lastPauseEnd := time.Unix(0, int64(stats.PauseEnd[(stats.NumGC+255)%256]))
	fmt.Printf("Last Pause Ended: %s\n", lastPauseEnd.Format(time.RFC3339Nano))
}

func gcTuningReport() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== GC Tuning Report ===")

	gcPercent := debug.SetGCPercent(-1)
	debug.SetGCPercent(gcPercent)
	if gcPercent < 0 {
		fmt.Println("GOGC: off (GC disabled)")
	} else {
		fmt.Printf("GOGC: %d%%\n", gcPercent)
	}

	memLimit := debug.SetMemoryLimit(-1)
	const unlimitedMemLimit int64 = 1<<63 - 1
	if memLimit == unlimitedMemLimit {
		fmt.Println("GOMEMLIMIT: not set")
	} else {
		fmt.Printf("GOMEMLIMIT: %s\n", formatBytes(uint64(memLimit)))
	}

	if stats.NumGC > 0 {
		avgHeapBetweenGC := stats.TotalAlloc / uint64(stats.NumGC)
		fmt.Printf("Average Allocation per GC Cycle: %s\n", formatBytes(avgHeapBetweenGC))
	}

	fmt.Printf("GC CPU Overhead: %.2f%%\n", stats.GCCPUFraction*100)
	if stats.GCCPUFraction > 0.05 {
		fmt.Println("WARNING: GC overhead is high (>5%)")
		fmt.Println("Consider: Increasing GOGC or reducing allocation rate")
	}

	if stats.HeapAlloc > 0 && stats.NextGC > 0 {
		growthRatio := float64(stats.NextGC) / float64(stats.HeapAlloc)
		fmt.Printf("Heap Growth Ratio (NextGC/HeapAlloc): %.2fx\n", growthRatio)
	}

	if stats.HeapInuse > 0 {
		retentionRatio := float64(stats.HeapIdle) / float64(stats.HeapInuse)
		fmt.Printf("Idle/Inuse Ratio: %.2f\n", retentionRatio)

		if retentionRatio > 2.0 {
			fmt.Println("INFO: High idle memory ratio")
			fmt.Println("Consider: debug.FreeOSMemory() to release memory to OS")
		}
	}

	if stats.NumGC > 0 {
		avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
		if avgPause > time.Millisecond {
			fmt.Printf(
				"WARNING: Average GC pause (%.2fms) exceeds 1ms\n",
				float64(avgPause)/float64(time.Millisecond),
			)
			fmt.Println("Consider: Reducing heap size or live object count")
		}
	}
}

func (s *server) issueJWT() (string, error) {
	claims := jwt.RegisteredClaims{
		Subject:   s.adminUser,
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

func (s *server) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			writeError(w, http.StatusUnauthorized, "missing bearer token")
			return
		}

		tokenString := strings.TrimPrefix(header, "Bearer ")
		claims := &jwt.RegisteredClaims{}
		token, err := jwt.ParseWithClaims(
			tokenString,
			claims,
			func(token *jwt.Token) (any, error) {
				if token.Method != jwt.SigningMethodHS256 {
					return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
				}
				return s.jwtSecret, nil
			},
		)
		if err != nil || !token.Valid {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		next.ServeHTTP(w, r)
	})
}

// handleHealth godoc
//
//	@Summary		ヘルスチェック
//	@Description	サーバーの稼働状態を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	healthResponse
//	@Router			/ [get]
func (s *server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, healthResponse{Status: "ok"})
}

// handleGetCounter godoc
//
//	@Summary		PVカウンター
//	@Description	現在のページビュー数を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	countResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Router			/counter [get]
func (s *server) handleGetCounter(w http.ResponseWriter, r *http.Request) {
	var current int
	err := s.db.QueryRow(
		"SELECT count FROM views WHERE id = 1",
	).Scan(&current)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "counter not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, countResponse{Count: current})
}

// handleIncrementCounter godoc
//
//	@Summary		PVカウンター加算
//	@Description	ページビュー数をインクリメントして現在値を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	countResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Router			/counter [post]
func (s *server) handleIncrementCounter(w http.ResponseWriter, r *http.Request) {
	var current int
	err := s.db.QueryRow(
		"UPDATE views SET count = count + 1 WHERE id = 1 RETURNING count",
	).Scan(&current)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "counter not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, countResponse{Count: current})
}

// handleLogin godoc
//
//	@Summary		管理者ログイン
//	@Description	ユーザー名・パスワードで認証し JWT を発行する
//	@Tags			auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		loginRequest	true	"認証情報"
//	@Success		200		{object}	loginResponse
//	@Failure		400		{object}	errorResponse
//	@Failure		401		{object}	errorResponse
//	@Failure		500		{object}	errorResponse
//	@Router			/api/admin/login [post]
func (s *server) recordLoginLog(username string, success bool, r *http.Request) {
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip = r.RemoteAddr
	}
	ua := r.UserAgent()

	_, err := s.db.Exec(
		`INSERT INTO login_logs (username, success, ip_address, user_agent) VALUES ($1, $2, $3, $4)`,
		username, success, ip, ua,
	)
	if err != nil {
		log.Printf("failed to record login log: %v", err)
	}
}

func (s *server) handleLogin(w http.ResponseWriter, r *http.Request) {
	var payload loginRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid login payload")
		return
	}

	if payload.Username != s.adminUser || payload.Password != s.adminPassword {
		s.recordLoginLog(payload.Username, false, r)
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	token, err := s.issueJWT()
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create token")
		return
	}

	s.recordLoginLog(payload.Username, true, r)
	writeJSON(w, http.StatusOK, loginResponse{Token: token})
}

// handleListQuizzes godoc
//
//	@Summary		クイズ一覧取得
//	@Description	検索・フィルター・ソート・ページネーション付きでクイズ一覧を返す
//	@Tags			quizzes
//	@Produce		json
//	@Param			title		query		string	false	"タイトル部分一致"
//	@Param			section		query		string	false	"セクション完全一致"
//	@Param			status		query		string	false	"公開状態"	Enums(published, unpublished)
//	@Param			sort		query		string	false	"ソート順"	Enums(updated_newest, updated_oldest, created_newest, created_oldest)	default(updated_newest)
//	@Param			page		query		int		false	"ページ番号"	minimum(1)	default(1)
//	@Param			per_page	query		int		false	"1ページあたり件数"	minimum(1)	maximum(100)	default(20)
//	@Success		200			{object}	quizListResponse
//	@Failure		401			{object}	errorResponse
//	@Failure		500			{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes [get]
func (s *server) handleListQuizzes(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()

	// ページネーション
	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}
	perPage, _ := strconv.Atoi(q.Get("per_page"))
	if perPage < 1 || perPage > 100 {
		perPage = 20
	}

	// フィルター条件を構築
	where := []string{"1=1"}
	args := []any{}
	argIdx := 1

	if title := strings.TrimSpace(q.Get("title")); title != "" {
		where = append(where, fmt.Sprintf("title ILIKE $%d", argIdx))
		args = append(args, "%"+title+"%")
		argIdx++
	}
	if section := strings.TrimSpace(q.Get("section")); section != "" {
		where = append(where, fmt.Sprintf("section = $%d", argIdx))
		args = append(args, section)
		argIdx++
	}
	if status := strings.TrimSpace(q.Get("status")); status == "published" || status == "unpublished" {
		where = append(where, fmt.Sprintf("status = $%d", argIdx))
		args = append(args, status)
		argIdx++
	}

	whereClause := strings.Join(where, " AND ")

	// 総件数を取得
	var total int
	countQuery := "SELECT COUNT(*) FROM quizzes WHERE " + whereClause
	if err := s.db.QueryRow(countQuery, args...).Scan(&total); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	// ソート順
	orderBy := "updated_at DESC, id DESC"
	switch q.Get("sort") {
	case "created_newest":
		orderBy = "created_at DESC, id DESC"
	case "created_oldest":
		orderBy = "created_at ASC, id ASC"
	case "updated_oldest":
		orderBy = "updated_at ASC, id ASC"
	}

	// データ取得
	offset := (page - 1) * perPage
	dataQuery := fmt.Sprintf(`
		SELECT
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
		FROM quizzes
		WHERE %s
		ORDER BY %s
		LIMIT $%d OFFSET $%d
	`, whereClause, orderBy, argIdx, argIdx+1)
	args = append(args, perPage, offset)

	rows, err := s.db.Query(dataQuery, args...)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	items := make([]quiz, 0)
	for rows.Next() {
		item, err := scanQuiz(rows)
		if err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	totalPages := (total + perPage - 1) / perPage
	writeJSON(w, http.StatusOK, quizListResponse{
		Items:      items,
		Total:      total,
		Page:       page,
		PerPage:    perPage,
		TotalPages: totalPages,
	})
}

// handleGetQuiz godoc
//
//	@Summary		クイズ詳細取得
//	@Description	指定IDのクイズを返す
//	@Tags			quizzes
//	@Produce		json
//	@Param			id	path		int	true	"クイズID"
//	@Success		200	{object}	quiz
//	@Failure		400	{object}	errorResponse
//	@Failure		401	{object}	errorResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes/{id} [get]
func (s *server) handleGetQuiz(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	item, err := scanQuiz(s.db.QueryRow(`
		SELECT
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
		FROM quizzes
		WHERE id = $1
	`, quizID))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "quiz not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, item)
}

// handleCreateQuiz godoc
//
//	@Summary		クイズ新規作成
//	@Description	新しいクイズを作成して返す
//	@Tags			quizzes
//	@Accept			json
//	@Produce		json
//	@Param			body	body		quizPayload	true	"クイズデータ"
//	@Success		201		{object}	quiz
//	@Failure		400		{object}	errorResponse
//	@Failure		401		{object}	errorResponse
//	@Failure		500		{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes [post]
func (s *server) handleCreateQuiz(w http.ResponseWriter, r *http.Request) {
	var payload quizPayload
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid quiz payload")
		return
	}

	if err := normalizeQuizPayload(&payload); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	optionsJSON, err := json.Marshal(payload.Options)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to encode options")
		return
	}

	var codeValue any
	if payload.Code == "" {
		codeValue = nil
	} else {
		codeValue = payload.Code
	}

	item, err := scanQuiz(s.db.QueryRow(`
		INSERT INTO quizzes (
			section, title, question, code, options,
			correct_answer_index, explanation, source, status, push_enabled
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
	`,
		payload.Section,
		payload.Title,
		payload.Question,
		codeValue,
		optionsJSON,
		payload.CorrectAnswerIndex,
		payload.Explanation,
		payload.Source,
		payload.Status,
		payload.PushEnabled,
	))
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, item)
}

// handleUpdateQuiz godoc
//
//	@Summary		クイズ更新
//	@Description	指定IDのクイズを更新して返す
//	@Tags			quizzes
//	@Accept			json
//	@Produce		json
//	@Param			id		path		int			true	"クイズID"
//	@Param			body	body		quizPayload	true	"クイズデータ"
//	@Success		200		{object}	quiz
//	@Failure		400		{object}	errorResponse
//	@Failure		401		{object}	errorResponse
//	@Failure		404		{object}	errorResponse
//	@Failure		500		{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes/{id} [put]
func (s *server) handleUpdateQuiz(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	var payload quizPayload
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid quiz payload")
		return
	}

	if err := normalizeQuizPayload(&payload); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	optionsJSON, err := json.Marshal(payload.Options)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to encode options")
		return
	}

	var codeValue any
	if payload.Code == "" {
		codeValue = nil
	} else {
		codeValue = payload.Code
	}

	item, err := scanQuiz(s.db.QueryRow(`
		UPDATE quizzes
		SET
			section = $2,
			title = $3,
			question = $4,
			code = $5,
			options = $6,
			correct_answer_index = $7,
			explanation = $8,
			source = $9,
			status = $10,
			push_enabled = $11,
			updated_at = NOW()
		WHERE id = $1
		RETURNING
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
	`,
		quizID,
		payload.Section,
		payload.Title,
		payload.Question,
		codeValue,
		optionsJSON,
		payload.CorrectAnswerIndex,
		payload.Explanation,
		payload.Source,
		payload.Status,
		payload.PushEnabled,
	))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "quiz not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, item)
}

// handleDeleteQuiz godoc
//
//	@Summary		クイズ削除
//	@Description	指定IDのクイズを削除する
//	@Tags			quizzes
//	@Param			id	path	int	true	"クイズID"
//	@Success		204	"No Content"
//	@Failure		400	{object}	errorResponse
//	@Failure		401	{object}	errorResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes/{id} [delete]
func (s *server) handleDeleteQuiz(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	result, err := s.db.Exec(`DELETE FROM quizzes WHERE id = $1`, quizID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	if rowsAffected == 0 {
		writeError(w, http.StatusNotFound, "quiz not found")
		return
	}

	writeJSON(w, http.StatusNoContent, nil)
}

// handleToggleStatus godoc
//
//	@Summary		公開状態トグル
//	@Description	指定IDのクイズの公開状態を反転する（published ↔ unpublished）
//	@Tags			quizzes
//	@Produce		json
//	@Param			id	path		int	true	"クイズID"
//	@Success		200	{object}	quiz
//	@Failure		400	{object}	errorResponse
//	@Failure		401	{object}	errorResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes/{id}/status [patch]
func (s *server) handleToggleStatus(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	item, err := scanQuiz(s.db.QueryRow(`
		UPDATE quizzes
		SET status = CASE WHEN status = 'published' THEN 'unpublished' ELSE 'published' END,
		    updated_at = NOW()
		WHERE id = $1
		RETURNING
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
	`, quizID))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "quiz not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, item)
}

// handleTogglePush godoc
//
//	@Summary		PUSH通知トグル
//	@Description	指定IDのクイズのPUSH通知設定を反転する（true ↔ false）
//	@Tags			quizzes
//	@Produce		json
//	@Param			id	path		int	true	"クイズID"
//	@Success		200	{object}	quiz
//	@Failure		400	{object}	errorResponse
//	@Failure		401	{object}	errorResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Security		BearerAuth
//	@Router			/api/admin/quizzes/{id}/push [patch]
func (s *server) handleTogglePush(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	item, err := scanQuiz(s.db.QueryRow(`
		UPDATE quizzes
		SET push_enabled = NOT push_enabled,
		    updated_at = NOW()
		WHERE id = $1
		RETURNING
			id, section, title, question, code, options,
			correct_answer_index, explanation, source,
			status, push_enabled, created_at, updated_at
	`, quizID))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "quiz not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, item)
}

func withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Vary", "Origin")
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (s *server) routes() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /", s.handleHealth)
	mux.HandleFunc("GET /counter", s.handleGetCounter)
	mux.HandleFunc("POST /counter", s.handleIncrementCounter)
	mux.HandleFunc("POST /api/admin/login", s.handleLogin)
	mux.Handle("GET /api/admin/quizzes", s.requireAuth(http.HandlerFunc(s.handleListQuizzes)))
	mux.Handle("GET /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleGetQuiz)))
	mux.Handle("POST /api/admin/quizzes", s.requireAuth(http.HandlerFunc(s.handleCreateQuiz)))
	mux.Handle("PUT /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleUpdateQuiz)))
	mux.Handle("DELETE /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleDeleteQuiz)))
	mux.Handle("PATCH /api/admin/quizzes/{id}/status", s.requireAuth(http.HandlerFunc(s.handleToggleStatus)))
	mux.Handle("PATCH /api/admin/quizzes/{id}/push", s.requireAuth(http.HandlerFunc(s.handleTogglePush)))

	return withCORS(mux)
}

// @title			Quiz Admin API
// @version		1.0
// @description	クイズ管理アプリケーションのバックエンドAPI
// @host			localhost:8080
// @BasePath		/
//
// @securityDefinitions.apikey	BearerAuth
// @in							header
// @name						Authorization
// @description				Bearer トークンを入力（例: Bearer eyJhbG...）
func main() {
	v, _ := mem.VirtualMemory()
	fmt.Printf("OS全体の使用中: %.2f%%\n", v.UsedPercent)
	fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())
	fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))
	fmt.Printf("Go Version: %s\n", runtime.Version())
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	logMemoryStats()
	analyzeNonHeapMemory()
	runtime.GC()
	analyzeGC()
	analyzeGCPauses()
	gcTuningReport()

	// ワーカー生成前のゴルーチン数を確認する
	initial := runtime.NumGoroutine()
	fmt.Printf("初期ゴルーチン数: %d\n", initial)

	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func(id int) {
			time.Sleep(2 * time.Second)
			done <- true
		}(i)
	}
	// ワーカー生成後のゴルーチン数を確認する
	afterSpawn := runtime.NumGoroutine()
	fmt.Printf("ワーカー生成後: %d\n", afterSpawn)
	analyzeNonHeapMemory()

	// 全ワーカーの完了を待つ
	for i := 0; i < 10; i++ {
		<-done
	}

	// ランタイムがクリーンアップする時間を少し与える
	time.Sleep(100 * time.Millisecond)

	// 最終数を確認する — 初期値に戻っているはず
	final := runtime.NumGoroutine()
	fmt.Printf("最終ゴルーチン数: %d\n", final)
	analyzeNonHeapMemory()

	// ゴルーチンリークの可能性を検出する
	if final > initial {
		fmt.Printf("警告: ゴルーチンリークの可能性を検出！リーク数: %d\n", final-initial)
	}

	db, err := initDB()
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	s := &server{
		db:            db,
		adminUser:     getEnv("ADMIN_USER", "admin"),
		adminPassword: getEnv("ADMIN_PASSWORD", "password"),
		jwtSecret:     []byte(getEnv("JWT_SECRET", "dev-only-secret")),
	}

	if err := http.ListenAndServe(":8080", s.routes()); err != nil {
		log.Fatal(err)
	}
}
