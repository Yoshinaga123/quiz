package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
)

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
