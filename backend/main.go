package main

import (
	"bytes"
	"context"
	"crypto/rand"
	"database/sql"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math/big"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"runtime/debug"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	"github.com/lib/pq"
	"github.com/shirou/gopsutil/mem"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

const verificationPrompt = "quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。"
const defaultProductionSeedPath = "seeds/quizzes.production.json"
const defaultMigrationsDir = "migrations"
const defaultSeedMigrationName = "seed_quizzes"
const defaultSeedGeneratorScript = "../scripts/generate_migration.py"

type server struct {
	db                   *sql.DB
	adminUser            string
	adminPassword        string
	jwtSecret            []byte
	verificationMu       sync.Mutex
	pendingVerifications map[string]verificationChallenge
	seedMu               sync.Mutex
}

type rowScanner interface {
	Scan(dest ...any) error
}

type errorResponse struct {
	Error  string `json:"error"`
	Detail string `json:"detail,omitempty"`
}

type healthResponse struct {
	Status string `json:"status"`
}

type countResponse struct {
	Count int `json:"count"`
}

type loginRequest struct {
	Username         string `json:"username"`
	Password         string `json:"password"`
	ChallengeID      string `json:"challengeId"`
	VerificationCode string `json:"verificationCode"`
}

type loginResponse struct {
	Token string `json:"token"`
}

type verificationResponse struct {
	Message     string `json:"message"`
	ChallengeID string `json:"challengeId"`
	Code        string `json:"code,omitempty"`
}

type verificationChallenge struct {
	Username  string
	Code      string
	ExpiresAt time.Time
}

func generateChallengeID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return fmt.Sprintf("%x", b), nil
}

func generateVerificationCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
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

type productionSeedDocument struct {
	Quizzes []productionSeedQuiz `json:"quizzes"`
}

type productionSeedQuiz struct {
	ID                 int64    `json:"id"`
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               *string  `json:"code,omitempty"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
}

type productionSeedSyncResponse struct {
	SeededCount      int    `json:"seededCount"`
	DeletedCount     int    `json:"deletedCount"`
	Source           string `json:"source"`
	MigrationVersion int    `json:"migrationVersion"`
	UpPath           string `json:"upPath"`
	DownPath         string `json:"downPath"`
}

// publicQuiz は公開 API (/v1/quizzes) で返す、個人情報を含まないクイズの形状。
// docs/api/public-quiz-api.yaml の #/components/schemas/Quiz と構造を一致させ、
// 管理用フィールド (status, pushEnabled, createdAt, updatedAt) は意図的に除外する。
type publicQuiz struct {
	ID                 int64    `json:"id"`
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               *string  `json:"code,omitempty"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
}

type publicQuizListResponse struct {
	Quizzes     []publicQuiz `json:"quizzes"`
	TotalCount  int          `json:"totalCount"`
	GeneratedAt time.Time    `json:"generatedAt"`
}

type sectionSummary struct {
	Section string `json:"section"`
	Count   int    `json:"count"`
}

type publicSectionListResponse struct {
	Sections []sectionSummary `json:"sections"`
}

// publicErrorResponse は ADR 0006 で合意した公開 API のエラー形式。
// 管理 API の errorResponse とは別フォーマットとし、
// クライアント（web, mobile）は `code` でハンドリングできる。
type publicErrorResponse struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details,omitempty"`
}

type statusError struct {
	Status  int
	Message string
	Err     error
}

func (e *statusError) Error() string {
	if e.Message != "" {
		return e.Message
	}
	if e.Err != nil {
		return e.Err.Error()
	}
	return http.StatusText(e.Status)
}

func (e *statusError) Unwrap() error {
	return e.Err
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getMigrationsDir() string {
	return getEnv("QUIZ_MIGRATIONS_DIR", defaultMigrationsDir)
}

func getSeedGeneratorScriptPath() (string, error) {
	candidates := []string{
		os.Getenv("QUIZ_SEED_GENERATOR_SCRIPT"),
		defaultSeedGeneratorScript,
		filepath.Join("scripts", "generate_migration.py"),
	}

	for _, candidate := range candidates {
		if candidate == "" {
			continue
		}

		info, err := os.Stat(candidate)
		if err == nil && !info.IsDir() {
			return candidate, nil
		}
	}

	return "", fmt.Errorf("seed generator script not found")
}

func getMigrateBinaryPath() (string, error) {
	if value := os.Getenv("QUIZ_MIGRATE_BIN"); value != "" {
		return value, nil
	}

	if path, err := exec.LookPath("migrate"); err == nil {
		return path, nil
	}

	candidates := []string{
		"/go/bin/migrate",
		filepath.Join(os.Getenv("HOME"), ".local", "bin", "migrate"),
	}
	for _, candidate := range candidates {
		if candidate == "" {
			continue
		}
		info, err := os.Stat(candidate)
		if err == nil && !info.IsDir() {
			return candidate, nil
		}
	}

	return "", fmt.Errorf("migrate binary not found")
}

func runCommand(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	output, err := cmd.CombinedOutput()
	outputText := strings.TrimSpace(string(output))
	if err != nil {
		if outputText == "" {
			return "", err
		}
		return "", fmt.Errorf("%w: %s", err, outputText)
	}
	return outputText, nil
}

func runCommandStdout(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	output, err := cmd.Output()
	outputText := strings.TrimSpace(string(output))
	stderrText := strings.TrimSpace(stderr.String())
	if err != nil {
		if stderrText == "" {
			return "", err
		}
		return "", fmt.Errorf("%w: %s", err, stderrText)
	}

	return outputText, nil
}

func newMigrator(db *sql.DB) (*migrate.Migrate, error) {
	dbDriver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		return nil, err
	}

	migrationsDir := getMigrationsDir()
	if info, err := os.Stat(migrationsDir); err == nil && info.IsDir() {
		absDir, err := filepath.Abs(migrationsDir)
		if err != nil {
			return nil, err
		}

		return migrate.NewWithDatabaseInstance("file://"+absDir, "postgres", dbDriver)
	}

	srcDriver, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		return nil, err
	}

	return migrate.NewWithInstance("iofs", srcDriver, "postgres", dbDriver)
}

func databaseDSN() string {
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "password")
	name := getEnv("DB_NAME", "counter")

	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host,
		port,
		user,
		password,
		name,
	)
}

func openAppDB() (*sql.DB, error) {
	db, err := sql.Open("postgres", databaseDSN())
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		_ = db.Close()
		return nil, err
	}

	return db, nil
}

func initDB() (*sql.DB, error) {
	if err := runMigrations(); err != nil {
		return nil, fmt.Errorf("migration: %w", err)
	}

	return openAppDB()
}

func runMigrations() error {
	db, err := openAppDB()
	if err != nil {
		return err
	}

	m, err := newMigrator(db)
	if err != nil {
		_ = db.Close()
		return err
	}
	defer func() {
		sourceErr, databaseErr := m.Close()
		if sourceErr != nil {
			log.Printf("close migration source: %v", sourceErr)
		}
		if databaseErr != nil {
			log.Printf("close migration database: %v", databaseErr)
		}
	}()

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

func normalizeProductionSeedQuiz(payload *productionSeedQuiz) error {
	payload.Section = strings.TrimSpace(payload.Section)
	payload.Title = strings.TrimSpace(payload.Title)
	payload.Question = strings.TrimSpace(payload.Question)
	payload.Explanation = strings.TrimSpace(payload.Explanation)
	payload.Source = strings.TrimSpace(payload.Source)

	if payload.Code != nil {
		trimmed := strings.TrimSpace(*payload.Code)
		if trimmed == "" {
			payload.Code = nil
		} else {
			payload.Code = &trimmed
		}
	}

	if payload.ID <= 0 {
		return errors.New("id must be positive")
	}
	if payload.Section == "" {
		return fmt.Errorf("section is required for quiz id %d", payload.ID)
	}
	if payload.Title == "" {
		return fmt.Errorf("title is required for quiz id %d", payload.ID)
	}
	if payload.Question == "" {
		return fmt.Errorf("question is required for quiz id %d", payload.ID)
	}
	if payload.Explanation == "" {
		return fmt.Errorf("explanation is required for quiz id %d", payload.ID)
	}
	if payload.Source == "" {
		return fmt.Errorf("source is required for quiz id %d", payload.ID)
	}
	if len(payload.Options) < 2 {
		return fmt.Errorf("at least two options are required for quiz id %d", payload.ID)
	}

	for index := range payload.Options {
		payload.Options[index] = strings.TrimSpace(payload.Options[index])
		if payload.Options[index] == "" {
			return fmt.Errorf("option %d is required for quiz id %d", index+1, payload.ID)
		}
	}

	if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
		return fmt.Errorf("correctAnswerIndex is out of range for quiz id %d", payload.ID)
	}

	return nil
}

func validateProductionSeedDocument(document *productionSeedDocument) error {
	seenIDs := make(map[int64]struct{}, len(document.Quizzes))
	for _, quiz := range document.Quizzes {
		if _, exists := seenIDs[quiz.ID]; exists {
			return fmt.Errorf("duplicate quiz id in production seed: %d", quiz.ID)
		}
		seenIDs[quiz.ID] = struct{}{}
	}

	return nil
}

func getProductionSeedPath() string {
	if value := os.Getenv("QUIZ_PRODUCTION_SEED_PATH"); value != "" {
		return value
	}
	return defaultProductionSeedPath
}

func loadProductionSeedDocument(seedPath string) (productionSeedDocument, error) {
	content, err := os.ReadFile(seedPath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return productionSeedDocument{}, &statusError{
				Status:  http.StatusNotFound,
				Message: fmt.Sprintf("production seed file not found: %s", seedPath),
				Err:     err,
			}
		}
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: fmt.Sprintf("failed to read production seed file: %s", seedPath),
			Err:     err,
		}
	}

	var document productionSeedDocument
	if err := json.Unmarshal(content, &document); err != nil {
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusUnprocessableEntity,
			Message: fmt.Sprintf("production seed JSON is invalid: %s", seedPath),
			Err:     err,
		}
	}

	for index := range document.Quizzes {
		if err := normalizeProductionSeedQuiz(&document.Quizzes[index]); err != nil {
			return productionSeedDocument{}, &statusError{
				Status:  http.StatusUnprocessableEntity,
				Message: err.Error(),
				Err:     err,
			}
		}
	}

	if err := validateProductionSeedDocument(&document); err != nil {
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusUnprocessableEntity,
			Message: err.Error(),
			Err:     err,
		}
	}

	return document, nil
}

func countDeletedQuizzes(ctx context.Context, db *sql.DB, ids []int64) (int, error) {
	var deletedCount int

	if len(ids) == 0 {
		if err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM quizzes`).Scan(&deletedCount); err != nil {
			return 0, err
		}
		return deletedCount, nil
	}

	if err := db.QueryRowContext(
		ctx,
		`SELECT COUNT(*) FROM quizzes WHERE NOT (id = ANY($1))`,
		pq.Array(ids),
	).Scan(&deletedCount); err != nil {
		return 0, err
	}

	return deletedCount, nil
}

func parseCreatedMigrationPaths(output string) (string, string, error) {
	lines := strings.Split(output, "\n")
	var upPath string
	var downPath string

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}

		if strings.HasSuffix(trimmed, ".up.sql") {
			upPath = filepath.ToSlash(trimmed)
		}
		if strings.HasSuffix(trimmed, ".down.sql") {
			downPath = filepath.ToSlash(trimmed)
		}
	}

	if upPath == "" || downPath == "" {
		return "", "", fmt.Errorf("unexpected migrate create output: %s", output)
	}

	return upPath, downPath, nil
}

func migrationVersionFromPath(path string) (int, error) {
	base := filepath.Base(path)
	underscore := strings.IndexByte(base, '_')
	if underscore <= 0 {
		return 0, fmt.Errorf("invalid migration filename: %s", base)
	}
	return strconv.Atoi(base[:underscore])
}

func generateProductionSeedMigrationSQL(ctx context.Context, mode, seedPath string) (string, error) {
	scriptPath, err := getSeedGeneratorScriptPath()
	if err != nil {
		return "", fmt.Errorf("locate seed generator script: %w", err)
	}

	pythonBin := getEnv("QUIZ_PYTHON_BIN", "python3")
	log.Printf("[migration] generating %s SQL: %s %s --mode %s --input %s", mode, pythonBin, scriptPath, mode, seedPath)

	output, err := runCommandStdout(
		ctx,
		pythonBin,
		scriptPath,
		"--mode",
		mode,
		"--input",
		seedPath,
		"--source-label",
		filepath.Base(seedPath),
	)
	if err != nil {
		return "", fmt.Errorf("run %s %s (mode=%s): %w", pythonBin, scriptPath, mode, err)
	}

	if output == "" {
		return "", fmt.Errorf("generated %s SQL is empty (script=%s, input=%s)", mode, scriptPath, seedPath)
	}

	log.Printf("[migration] generated %s SQL: %d bytes", mode, len(output))
	return output + "\n", nil
}

func displayMigrationPath(actualPath string) string {
	migrationsDir := getMigrationsDir()
	filename := filepath.Base(actualPath)
	if filepath.IsAbs(migrationsDir) {
		return filepath.ToSlash(filepath.Join(migrationsDir, filename))
	}
	return filepath.ToSlash(filepath.Join("backend", migrationsDir, filename))
}

func createProductionSeedMigrationFiles(ctx context.Context, seedPath string) (int, string, string, error) {
	migrationsDir := getMigrationsDir()
	log.Printf("[migration] migrationsDir=%s, seedPath=%s", migrationsDir, seedPath)

	if err := os.MkdirAll(migrationsDir, 0o755); err != nil {
		return 0, "", "", fmt.Errorf("mkdir %s: %w", migrationsDir, err)
	}

	migrateBin, err := getMigrateBinaryPath()
	if err != nil {
		return 0, "", "", fmt.Errorf("locate migrate binary: %w", err)
	}
	log.Printf("[migration] migrate binary: %s", migrateBin)

	createOutput, err := runCommand(
		ctx,
		migrateBin,
		"create",
		"-ext",
		"sql",
		"-dir",
		migrationsDir,
		"-seq",
		"-digits",
		"3",
		defaultSeedMigrationName,
	)
	if err != nil {
		return 0, "", "", fmt.Errorf("migrate create: %w", err)
	}
	log.Printf("[migration] migrate create output: %s", createOutput)

	upRelativePath, downRelativePath, err := parseCreatedMigrationPaths(createOutput)
	if err != nil {
		return 0, "", "", fmt.Errorf("parse migration paths from output %q: %w", createOutput, err)
	}
	log.Printf("[migration] up=%s, down=%s", upRelativePath, downRelativePath)

	version, err := migrationVersionFromPath(upRelativePath)
	if err != nil {
		return 0, "", "", fmt.Errorf("extract version from %s: %w", upRelativePath, err)
	}

	upSQL, err := generateProductionSeedMigrationSQL(ctx, "up", seedPath)
	if err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("generate up SQL: %w", err)
	}

	downSQL, err := generateProductionSeedMigrationSQL(ctx, "down", seedPath)
	if err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("generate down SQL: %w", err)
	}

	if err := os.WriteFile(upRelativePath, []byte(upSQL), 0o644); err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("write %s: %w", upRelativePath, err)
	}
	if err := os.WriteFile(downRelativePath, []byte(downSQL), 0o644); err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("write %s: %w", downRelativePath, err)
	}

	log.Printf("[migration] created version %d successfully", version)
	return version, displayMigrationPath(upRelativePath), displayMigrationPath(downRelativePath), nil
}

func applyGeneratedMigrations() error {
	db, err := openAppDB()
	if err != nil {
		return err
	}

	m, err := newMigrator(db)
	if err != nil {
		_ = db.Close()
		return err
	}
	defer func() {
		sourceErr, databaseErr := m.Close()
		if sourceErr != nil {
			log.Printf("close migration source: %v", sourceErr)
		}
		if databaseErr != nil {
			log.Printf("close migration database: %v", databaseErr)
		}
	}()

	if err := m.Up(); err != nil {
		var dirtyErr migrate.ErrDirty
		if errors.As(err, &dirtyErr) {
			return &statusError{
				Status:  http.StatusConflict,
				Message: fmt.Sprintf("database is dirty at migration version %d", dirtyErr.Version),
				Err:     err,
			}
		}
		if errors.Is(err, migrate.ErrNoChange) {
			return nil
		}
		return &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to apply generated migration",
			Err:     err,
		}
	}

	return nil
}

func (s *server) syncProductionSeedQuizzes(ctx context.Context) (productionSeedSyncResponse, error) {
	seedPath := getProductionSeedPath()
	document, err := loadProductionSeedDocument(seedPath)
	if err != nil {
		return productionSeedSyncResponse{}, err
	}

	ids := make([]int64, 0, len(document.Quizzes))
	for _, quiz := range document.Quizzes {
		ids = append(ids, quiz.ID)
	}

	deletedCount, err := countDeletedQuizzes(ctx, s.db, ids)
	if err != nil {
		return productionSeedSyncResponse{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to calculate replace impact",
			Err:     err,
		}
	}

	version, upPath, downPath, err := createProductionSeedMigrationFiles(ctx, seedPath)
	if err != nil {
		return productionSeedSyncResponse{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to generate production seed migration files",
			Err:     err,
		}
	}

	if err := applyGeneratedMigrations(); err != nil {
		return productionSeedSyncResponse{}, err
	}

	return productionSeedSyncResponse{
		SeededCount:      len(document.Quizzes),
		DeletedCount:     deletedCount,
		Source:           seedPath,
		MigrationVersion: version,
		UpPath:           upPath,
		DownPath:         downPath,
	}, nil
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

func (s *server) createVerificationChallenge(username string) (string, string, error) {
	challengeID, err := generateChallengeID()
	if err != nil {
		return "", "", err
	}
	code, err := generateVerificationCode()
	if err != nil {
		return "", "", err
	}

	s.verificationMu.Lock()
	s.pendingVerifications[challengeID] = verificationChallenge{
		Username:  username,
		Code:      code,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}
	s.verificationMu.Unlock()

	log.Printf("verification code for %s: %s (challenge %s)", username, code, challengeID)

	return challengeID, code, nil
}

func (s *server) consumeVerification(username, challengeID, code string) bool {
	s.verificationMu.Lock()
	defer s.verificationMu.Unlock()

	challenge, ok := s.pendingVerifications[challengeID]
	if !ok {
		return false
	}
	if challenge.Username != username {
		return false
	}
	if time.Now().After(challenge.ExpiresAt) {
		delete(s.pendingVerifications, challengeID)
		return false
	}
	if challenge.Code != code {
		return false
	}

	delete(s.pendingVerifications, challengeID)
	return true
}

func (s *server) handleRequestLoginVerification(w http.ResponseWriter, r *http.Request) {
	var payload loginRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid login payload")
		return
	}

	if payload.Username != s.adminUser || payload.Password != s.adminPassword {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	challengeID, code, err := s.createVerificationChallenge(payload.Username)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create verification challenge")
		return
	}

	writeJSON(w, http.StatusOK, verificationResponse{
		Message:     verificationPrompt,
		ChallengeID: challengeID,
		Code:        code,
	})
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

	if payload.ChallengeID == "" || payload.VerificationCode == "" {
		writeError(w, http.StatusBadRequest, "verification code required")
		return
	}

	if !s.consumeVerification(payload.Username, payload.ChallengeID, payload.VerificationCode) {
		s.recordLoginLog(payload.Username, false, r)
		writeError(w, http.StatusUnauthorized, "invalid or expired verification code")
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

func (s *server) handleSyncProductionQuizzes(w http.ResponseWriter, r *http.Request) {
	if !s.seedMu.TryLock() {
		writeError(w, http.StatusConflict, "production seed sync is already running")
		return
	}
	defer s.seedMu.Unlock()

	result, err := s.syncProductionSeedQuizzes(r.Context())
	if err != nil {
		var statusErr *statusError
		if errors.As(err, &statusErr) {
			detail := ""
			if statusErr.Err != nil {
				detail = statusErr.Err.Error()
			}
			log.Printf("[ERROR] syncProductionSeedQuizzes: %s: %v", statusErr.Message, statusErr.Err)
			writeJSON(w, statusErr.Status, errorResponse{Error: statusErr.Message, Detail: detail})
			return
		}

		log.Printf("[ERROR] syncProductionSeedQuizzes: %v", err)
		writeError(w, http.StatusInternalServerError, "failed to sync production seed")
		return
	}

	writeJSON(w, http.StatusOK, result)
}

// ---- Public API (ADR 0006) --------------------------------------------------
//
// /v1 プレフィックスの公開エンドポイント群。
// 管理 API (/api/admin/...) と違い、認証なしで呼べる読み取り系が中心。
// status = 'published' のクイズのみを返し、個人情報は含めない。
//
// 仕様: docs/api/public-quiz-api.yaml（OpenAPI 3.1）
// 実装方針: docs/adr/0006-public-quiz-api.md

const (
	publicErrCodeBadRequest   = "bad_request"
	publicErrCodeNotFound     = "not_found"
	publicErrCodeInternal     = "internal_error"
	publicMaxListLimit        = 100
	publicDefaultListLimit    = 100
	publicQuizSelectProjection = `
		id, section, title, question, code, options,
		correct_answer_index, explanation, source
	`
)

func writePublicError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, publicErrorResponse{Code: code, Message: message})
}

func scanPublicQuiz(scanner rowScanner) (publicQuiz, error) {
	var item publicQuiz
	var code sql.NullString
	var optionsJSON []byte

	if err := scanner.Scan(
		&item.ID,
		&item.Section,
		&item.Title,
		&item.Question,
		&code,
		&optionsJSON,
		&item.CorrectAnswerIndex,
		&item.Explanation,
		&item.Source,
	); err != nil {
		return publicQuiz{}, err
	}

	if code.Valid && code.String != "" {
		value := code.String
		item.Code = &value
	}

	if err := json.Unmarshal(optionsJSON, &item.Options); err != nil {
		return publicQuiz{}, err
	}

	return item, nil
}

func (s *server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	_, _ = io.WriteString(w, "ok")
}

func (s *server) handleListPublicQuizzes(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()

	where := []string{"status = 'published'"}
	args := []any{}
	argIdx := 1

	if section := strings.TrimSpace(q.Get("section")); section != "" {
		where = append(where, fmt.Sprintf("section = $%d", argIdx))
		args = append(args, section)
		argIdx++
	}

	limit := publicDefaultListLimit
	if raw := strings.TrimSpace(q.Get("limit")); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > publicMaxListLimit {
			writePublicError(
				w,
				http.StatusBadRequest,
				publicErrCodeBadRequest,
				fmt.Sprintf("limit must be an integer between 1 and %d", publicMaxListLimit),
			)
			return
		}
		limit = parsed
	}

	whereClause := strings.Join(where, " AND ")

	var total int
	countQuery := "SELECT COUNT(*) FROM quizzes WHERE " + whereClause
	if err := s.db.QueryRowContext(r.Context(), countQuery, args...).Scan(&total); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}

	dataQuery := fmt.Sprintf(`
		SELECT %s
		FROM quizzes
		WHERE %s
		ORDER BY id ASC
		LIMIT $%d
	`, publicQuizSelectProjection, whereClause, argIdx)
	args = append(args, limit)

	rows, err := s.db.QueryContext(r.Context(), dataQuery, args...)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}
	defer rows.Close()

	items := make([]publicQuiz, 0, limit)
	for rows.Next() {
		item, err := scanPublicQuiz(rows)
		if err != nil {
			writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, publicQuizListResponse{
		Quizzes:     items,
		TotalCount:  total,
		GeneratedAt: time.Now().UTC(),
	})
}

func (s *server) handleGetPublicQuiz(w http.ResponseWriter, r *http.Request) {
	quizID, err := parseID(r.PathValue("id"))
	if err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, err.Error())
		return
	}

	query := `
		SELECT ` + publicQuizSelectProjection + `
		FROM quizzes
		WHERE id = $1 AND status = 'published'
	`
	item, err := scanPublicQuiz(s.db.QueryRowContext(r.Context(), query, quizID))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writePublicError(w, http.StatusNotFound, publicErrCodeNotFound, "quiz not found")
			return
		}
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, item)
}

func (s *server) handleListPublicSections(w http.ResponseWriter, r *http.Request) {
	rows, err := s.db.QueryContext(r.Context(), `
		SELECT section, COUNT(*) AS count
		FROM quizzes
		WHERE status = 'published'
		GROUP BY section
		ORDER BY section ASC
	`)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}
	defer rows.Close()

	summaries := make([]sectionSummary, 0)
	for rows.Next() {
		var summary sectionSummary
		if err := rows.Scan(&summary.Section, &summary.Count); err != nil {
			writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
			return
		}
		summaries = append(summaries, summary)
	}
	if err := rows.Err(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, publicSectionListResponse{Sections: summaries})
}

// ---- end Public API ---------------------------------------------------------

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
	mux.HandleFunc("GET /healthz", s.handleHealthz)
	mux.HandleFunc("GET /counter", s.handleGetCounter)
	mux.HandleFunc("POST /counter", s.handleIncrementCounter)
	mux.HandleFunc("GET /v1/quizzes", s.handleListPublicQuizzes)
	mux.HandleFunc("GET /v1/quizzes/{id}", s.handleGetPublicQuiz)
	mux.HandleFunc("GET /v1/sections", s.handleListPublicSections)
	mux.HandleFunc("POST /api/admin/login/verification", s.handleRequestLoginVerification)
	mux.HandleFunc("POST /api/admin/login", s.handleLogin)
	mux.Handle("GET /api/admin/quizzes", s.requireAuth(http.HandlerFunc(s.handleListQuizzes)))
	mux.Handle("POST /api/admin/quizzes/sync-production", s.requireAuth(http.HandlerFunc(s.handleSyncProductionQuizzes)))
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
		db:                   db,
		adminUser:            getEnv("ADMIN_USER", "admin"),
		adminPassword:        getEnv("ADMIN_PASSWORD", "password"),
		jwtSecret:            []byte(getEnv("JWT_SECRET", "dev-only-secret")),
		pendingVerifications: make(map[string]verificationChallenge),
	}

	if err := http.ListenAndServe(":8080", s.routes()); err != nil {
		log.Fatal(err)
	}
}
