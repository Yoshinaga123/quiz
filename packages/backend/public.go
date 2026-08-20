package main

import (
	"database/sql"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

// ---- Public API (ADR 0006) --------------------------------------------------
//
// /v1 プレフィックスの公開エンドポイント群。
// 管理 API (/api/admin/...) と違い、認証なしで呼べる読み取り系が中心。
// status = 'published' のクイズのみを返し、個人情報は含めない。
//
// 仕様: docs/api/public-quiz-api.yaml（OpenAPI 3.1）
// 実装方針: docs/adr/0006-public-quiz-api.md

const (
	publicErrCodeBadRequest    = "bad_request"
	publicErrCodeNotFound      = "not_found"
	publicErrCodeInternal      = "internal_error"
	publicErrCodePushFeedNone  = "push_feed_not_found"
	publicMaxListLimit         = 100
	publicDefaultListLimit     = 100
	publicQuizSelectProjection = `
		id, section, title, question, code, options,
		correct_answer_index, explanation, source
	`
)

func (s *server) handleHealthz(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	_, _ = io.WriteString(w, "ok")
}

type publicListParams struct {
	section string
	limit   int
	offset  int
}

func parsePublicListParams(q url.Values) (publicListParams, string) {
	params := publicListParams{
		section: strings.TrimSpace(q.Get("section")),
		limit:   publicDefaultListLimit,
		offset:  0,
	}

	if raw := strings.TrimSpace(q.Get("limit")); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > publicMaxListLimit {
			return publicListParams{}, fmt.Sprintf("limit must be an integer between 1 and %d", publicMaxListLimit)
		}
		params.limit = parsed
	}

	if raw := strings.TrimSpace(q.Get("offset")); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 0 {
			return publicListParams{}, "offset must be an integer >= 0"
		}
		params.offset = parsed
	}

	return params, ""
}

func (s *server) handleListPublicQuizzes(w http.ResponseWriter, r *http.Request) {
	params, errMsg := parsePublicListParams(r.URL.Query())
	if errMsg != "" {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, errMsg)
		return
	}

	where := []string{"status = 'published'"}
	args := []any{}
	argIdx := 1

	if params.section != "" {
		where = append(where, fmt.Sprintf("section = $%d", argIdx))
		args = append(args, params.section)
		argIdx++
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
		LIMIT $%d OFFSET $%d
	`, publicQuizSelectProjection, whereClause, argIdx, argIdx+1)
	args = append(args, params.limit, params.offset)

	rows, err := s.db.QueryContext(r.Context(), dataQuery, args...)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}
	defer rows.Close()

	items := make([]publicQuiz, 0, params.limit)
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
