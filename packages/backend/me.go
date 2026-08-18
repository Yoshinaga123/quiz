package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/lib/pq"
)

const (
	publicErrCodeUnauthorized  = "unauthorized"
	publicErrCodeMemberDeleted = "member_deleted"
	publicMaxAnswerHistoryPage = 100
	defaultAnswerHistoryPage   = 20
)

type ctxKey string

const ctxKeyMemberID ctxKey = "memberID"

type publicMember struct {
	ID               string `json:"id"`
	Handle           string `json:"handle"`
	HasVerifiedEmail bool   `json:"hasVerifiedEmail"`
}

type answerHistoryEntry struct {
	ID            int64     `json:"id"`
	QuizID        int64     `json:"quizId"`
	SelectedIndex int       `json:"selectedIndex"`
	IsCorrect     bool      `json:"isCorrect"`
	AnsweredAt    time.Time `json:"answeredAt"`
}

type answerHistoryListResponse struct {
	Items []answerHistoryEntry `json:"items"`
}

type answerHistoryCreateRequest struct {
	QuizID        int64 `json:"quizId"`
	SelectedIndex int   `json:"selectedIndex"`
}

type answerHistoryCreateResponse struct {
	ID            int64     `json:"id"`
	QuizID        int64     `json:"quizId"`
	SelectedIndex int       `json:"selectedIndex"`
	IsCorrect     bool      `json:"isCorrect"`
	AnsweredAt    time.Time `json:"answeredAt"`
}

func (s *server) requireMemberAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "missing bearer token")
			return
		}
		tokenString := strings.TrimPrefix(header, "Bearer ")

		claims := &jwt.RegisteredClaims{}
		token, err := jwt.ParseWithClaims(
			tokenString,
			claims,
			func(t *jwt.Token) (any, error) {
				if t.Method != jwt.SigningMethodHS256 {
					return nil, fmt.Errorf("unexpected signing method: %s", t.Method.Alg())
				}
				return s.memberJWTSecret, nil
			},
		)
		if err != nil || !token.Valid {
			writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "invalid token")
			return
		}

		if !claimsHasAudience(claims, memberJWTAudience) {
			writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "invalid audience")
			return
		}
		if claims.Subject == "" {
			writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "missing subject")
			return
		}

		alive, err := s.memberIsActive(r.Context(), claims.Subject)
		if err != nil {
			writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to look up member")
			return
		}
		if !alive {
			writePublicError(w, http.StatusUnauthorized, publicErrCodeMemberDeleted, "member is deleted")
			return
		}

		ctx := context.WithValue(r.Context(), ctxKeyMemberID, claims.Subject)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func claimsHasAudience(c *jwt.RegisteredClaims, want string) bool {
	for _, aud := range c.Audience {
		if aud == want {
			return true
		}
	}
	return false
}

func memberIDFromContext(ctx context.Context) (string, bool) {
	id, ok := ctx.Value(ctxKeyMemberID).(string)
	return id, ok && id != ""
}

func (s *server) memberIsActive(ctx context.Context, id string) (bool, error) {
	var deletedAt sql.NullTime
	err := s.db.QueryRowContext(
		ctx,
		`SELECT deleted_at FROM members WHERE id = $1`,
		id,
	).Scan(&deletedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return !deletedAt.Valid, nil
}

func (s *server) handleGetMe(w http.ResponseWriter, r *http.Request) {
	id, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	var (
		handle          string
		emailVerifiedAt sql.NullTime
	)
	err := s.db.QueryRowContext(
		r.Context(),
		`SELECT handle, email_verified_at FROM members WHERE id = $1 AND deleted_at IS NULL`,
		id,
	).Scan(&handle, &emailVerifiedAt)
	if errors.Is(err, sql.ErrNoRows) {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeMemberDeleted, "member is deleted")
		return
	}
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load member")
		return
	}

	writeJSON(w, http.StatusOK, publicMember{
		ID:               id,
		Handle:           handle,
		HasVerifiedEmail: emailVerifiedAt.Valid,
	})
}

func (s *server) handleDeleteMe(w http.ResponseWriter, r *http.Request) {
	id, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	res, err := s.db.ExecContext(
		r.Context(),
		`UPDATE members SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL`,
		id,
	)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to delete member")
		return
	}
	if rows, _ := res.RowsAffected(); rows == 0 {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeMemberDeleted, "member is already deleted")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (s *server) handleCreateAnswerHistory(w http.ResponseWriter, r *http.Request) {
	id, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	var payload answerHistoryCreateRequest
	if err := decodeJSON(r, &payload); err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "invalid payload")
		return
	}
	if payload.QuizID < 1 {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "quizId must be an integer >= 1")
		return
	}
	if payload.SelectedIndex < 0 {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "selectedIndex must be an integer >= 0")
		return
	}

	var (
		correctIndex int
		historyID    int64
		answeredAt   time.Time
	)
	err := s.db.QueryRowContext(
		r.Context(),
		`SELECT correct_answer_index FROM quizzes WHERE id = $1`,
		payload.QuizID,
	).Scan(&correctIndex)
	if errors.Is(err, sql.ErrNoRows) {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "quizId not found")
		return
	}
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load quiz")
		return
	}

	err = s.db.QueryRowContext(
		r.Context(),
		`INSERT INTO answer_history (member_id, quiz_id, selected_index)
		 VALUES ($1, $2, $3)
		 RETURNING id, answered_at`,
		id, payload.QuizID, payload.SelectedIndex,
	).Scan(&historyID, &answeredAt)
	if err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && string(pqErr.Code) == "23503" {
			// FK to members(id) can only fail if the token subject is stale.
			writePublicError(w, http.StatusUnauthorized, publicErrCodeMemberDeleted, "member is deleted")
			return
		}
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to record answer")
		return
	}

	writeJSON(w, http.StatusCreated, answerHistoryCreateResponse{
		ID:            historyID,
		QuizID:        payload.QuizID,
		SelectedIndex: payload.SelectedIndex,
		IsCorrect:     payload.SelectedIndex == correctIndex,
		AnsweredAt:    answeredAt,
	})
}

func (s *server) handleListAnswerHistory(w http.ResponseWriter, r *http.Request) {
	id, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	limit := defaultAnswerHistoryPage
	if raw := r.URL.Query().Get("limit"); raw != "" {
		parsed, err := strconv.Atoi(raw)
		if err != nil || parsed < 1 || parsed > publicMaxAnswerHistoryPage {
			writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "limit must be an integer between 1 and 100")
			return
		}
		limit = parsed
	}

	var (
		rows *sql.Rows
		err  error
	)
	if raw := r.URL.Query().Get("quizId"); raw != "" {
		quizID, parseErr := strconv.ParseInt(raw, 10, 64)
		if parseErr != nil || quizID < 1 {
			writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "quizId must be an integer >= 1")
			return
		}
		rows, err = s.db.QueryContext(
			r.Context(),
			`SELECT ah.id, ah.quiz_id, ah.selected_index,
			        (ah.selected_index = q.correct_answer_index) AS is_correct,
			        ah.answered_at
			 FROM answer_history ah
			 JOIN quizzes q ON q.id = ah.quiz_id
			 WHERE ah.member_id = $1 AND ah.quiz_id = $2
			 ORDER BY ah.answered_at DESC, ah.id DESC
			 LIMIT $3`,
			id, quizID, limit,
		)
	} else {
		rows, err = s.db.QueryContext(
			r.Context(),
			`SELECT ah.id, ah.quiz_id, ah.selected_index,
			        (ah.selected_index = q.correct_answer_index) AS is_correct,
			        ah.answered_at
			 FROM answer_history ah
			 JOIN quizzes q ON q.id = ah.quiz_id
			 WHERE ah.member_id = $1
			 ORDER BY ah.answered_at DESC, ah.id DESC
			 LIMIT $2`,
			id, limit,
		)
	}
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load history")
		return
	}
	defer rows.Close()

	items := make([]answerHistoryEntry, 0, limit)
	for rows.Next() {
		var e answerHistoryEntry
		if err := rows.Scan(&e.ID, &e.QuizID, &e.SelectedIndex, &e.IsCorrect, &e.AnsweredAt); err != nil {
			writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to read history row")
			return
		}
		items = append(items, e)
	}
	if err := rows.Err(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to iterate history")
		return
	}

	writeJSON(w, http.StatusOK, answerHistoryListResponse{Items: items})
}
