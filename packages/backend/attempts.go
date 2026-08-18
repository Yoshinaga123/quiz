package main

import (
	"context"
	"database/sql"
	"errors"
	"net/http"
	"regexp"
	"strings"

	"github.com/lib/pq"
)

const (
	attemptAcceptedStatus   = "accepted"
	publicMaxAttemptAnswers = 100
)

var uuidPattern = regexp.MustCompile(`(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

func (s *server) handleSubmitAttempt(w http.ResponseWriter, r *http.Request) {
	var payload attemptCreateRequest
	if err := decodeJSON(r, &payload); err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, err.Error())
		return
	}

	if errMsg := validateAttemptCreate(payload); errMsg != "" {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, errMsg)
		return
	}

	if err := s.persistAttempt(r.Context(), payload); err != nil {
		var statusErr *statusError
		if errors.As(err, &statusErr) {
			code := publicErrCodeBadRequest
			if statusErr.Status >= 500 {
				code = publicErrCodeInternal
			}
			writePublicError(w, statusErr.Status, code, statusErr.Error())
			return
		}
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}

	writeJSON(w, http.StatusAccepted, attemptAccepted{
		ClientSessionID: payload.ClientSessionID,
		Status:          attemptAcceptedStatus,
	})
}

func validateAttemptCreate(payload attemptCreateRequest) string {
	if !uuidPattern.MatchString(strings.TrimSpace(payload.ClientSessionID)) {
		return "clientSessionId must be a UUID"
	}
	if payload.CompletedAt.IsZero() {
		return "completedAt is required"
	}
	if payload.Section != nil && strings.TrimSpace(*payload.Section) == "" {
		return "section must not be empty when provided"
	}
	if len(payload.Answers) == 0 {
		return "answers must contain at least one item"
	}
	if len(payload.Answers) > publicMaxAttemptAnswers {
		return "answers exceeds the maximum number of items"
	}

	seen := make(map[int64]struct{}, len(payload.Answers))
	for _, answer := range payload.Answers {
		if answer.QuizID < 1 {
			return "quizId must be an integer >= 1"
		}
		if answer.SelectedIndex < 0 {
			return "selectedIndex must be an integer >= 0"
		}
		if _, exists := seen[answer.QuizID]; exists {
			return "answers must not contain duplicate quizId"
		}
		seen[answer.QuizID] = struct{}{}
	}
	return ""
}

func (s *server) persistAttempt(ctx context.Context, payload attemptCreateRequest) error {
	quizIDs := make([]int64, 0, len(payload.Answers))
	correctCount := 0
	for _, answer := range payload.Answers {
		quizIDs = append(quizIDs, answer.QuizID)
		if answer.IsCorrect {
			correctCount++
		}
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		_ = tx.Rollback()
	}()

	var found int
	if err := tx.QueryRowContext(
		ctx,
		`SELECT COUNT(DISTINCT id) FROM quizzes WHERE id = ANY($1)`,
		pq.Array(quizIDs),
	).Scan(&found); err != nil {
		return err
	}
	if found != len(quizIDs) {
		return &statusError{Status: http.StatusBadRequest, Message: "one or more quizId values were not found"}
	}

	var section any
	if payload.Section != nil {
		section = strings.TrimSpace(*payload.Section)
	}

	var insertedID string
	err = tx.QueryRowContext(
		ctx,
		`
			INSERT INTO attempts (client_session_id, section, completed_at, total_count, correct_count)
			VALUES ($1, $2, $3, $4, $5)
			ON CONFLICT (client_session_id) DO NOTHING
			RETURNING client_session_id
		`,
		payload.ClientSessionID,
		section,
		payload.CompletedAt,
		len(payload.Answers),
		correctCount,
	).Scan(&insertedID)
	if errors.Is(err, sql.ErrNoRows) {
		return tx.Commit()
	}
	if err != nil {
		return err
	}

	for _, answer := range payload.Answers {
		if _, err := tx.ExecContext(
			ctx,
			`
				INSERT INTO attempt_answers (client_session_id, quiz_id, selected_index, is_correct, answered_at)
				VALUES ($1, $2, $3, $4, $5)
			`,
			payload.ClientSessionID,
			answer.QuizID,
			answer.SelectedIndex,
			answer.IsCorrect,
			answer.AnsweredAt,
		); err != nil {
			return err
		}
	}

	return tx.Commit()
}
