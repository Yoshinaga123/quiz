package main

import (
	"context"
	"database/sql"
	"errors"
	"log"
	"net/http"
	"strconv"
)

func buildMockPushBody(question string) string {
	return question
}

func (s *server) selectMockPushCandidate(ctx context.Context) (mockPushCandidate, error) {
	var candidate mockPushCandidate
	err := s.db.QueryRowContext(ctx, `
		SELECT id, title, question
		FROM quizzes
		WHERE status = 'published'
		  AND push_enabled = TRUE
		  AND NOT EXISTS (
		      SELECT 1
		      FROM push_deliveries
		      WHERE push_deliveries.quiz_id = quizzes.id
		        AND push_deliveries.sent_at >= NOW() - INTERVAL '7 days'
		  )
		ORDER BY id ASC
		LIMIT 1
	`).Scan(&candidate.QuizID, &candidate.Title, &candidate.Question)
	if err != nil {
		return mockPushCandidate{}, err
	}

	return candidate, nil
}

func (s *server) dispatchMockPush(ctx context.Context) (pushDispatchResponse, error) {
	candidate, err := s.selectMockPushCandidate(ctx)
	if err != nil {
		return pushDispatchResponse{}, err
	}

	response := pushDispatchResponse{Title: candidate.Title}
	err = s.db.QueryRowContext(ctx, `
		INSERT INTO push_deliveries (quiz_id, channel, target_count, status)
		VALUES ($1, $2, $3, $4)
		RETURNING id, quiz_id, channel, target_count, status, sent_at
	`, candidate.QuizID, "mock", 0, "mock_sent").Scan(
		&response.DeliveryID,
		&response.QuizID,
		&response.Channel,
		&response.TargetCount,
		&response.Status,
		&response.SentAt,
	)
	if err != nil {
		return pushDispatchResponse{}, err
	}

	log.Printf(
		"mock push dispatched: delivery_id=%d quiz_id=%d",
		response.DeliveryID,
		response.QuizID,
	)
	return response, nil
}

func (s *server) handleDispatchMockPush(w http.ResponseWriter, r *http.Request) {
	if !s.pushMu.TryLock() {
		writeError(w, http.StatusConflict, "mock push dispatch is already running")
		return
	}
	defer s.pushMu.Unlock()

	response, err := s.dispatchMockPush(r.Context())
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeJSON(w, http.StatusUnprocessableEntity, errorResponse{
				Error:  "no push candidates",
				Code:   "no_push_candidates",
				Detail: "no published quizzes with push enabled are available",
			})
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, response)
}

func (s *server) handleListPushDeliveries(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()

	page, _ := strconv.Atoi(q.Get("page"))
	if page < 1 {
		page = 1
	}
	perPage, _ := strconv.Atoi(q.Get("per_page"))
	if perPage < 1 || perPage > 100 {
		perPage = 20
	}

	var total int
	if err := s.db.QueryRowContext(r.Context(), `SELECT COUNT(*) FROM push_deliveries`).Scan(&total); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	offset := (page - 1) * perPage
	rows, err := s.db.QueryContext(r.Context(), `
		SELECT pd.id, pd.quiz_id, q.title, pd.channel, pd.target_count, pd.status, pd.error_detail, pd.sent_at
		FROM push_deliveries pd
		INNER JOIN quizzes q ON q.id = pd.quiz_id
		ORDER BY pd.sent_at DESC, pd.id DESC
		LIMIT $1 OFFSET $2
	`, perPage, offset)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	defer rows.Close()

	items := make([]pushDelivery, 0, perPage)
	for rows.Next() {
		var item pushDelivery
		var errorDetail sql.NullString
		if err := rows.Scan(
			&item.DeliveryID,
			&item.QuizID,
			&item.Title,
			&item.Channel,
			&item.TargetCount,
			&item.Status,
			&errorDetail,
			&item.SentAt,
		); err != nil {
			writeError(w, http.StatusInternalServerError, err.Error())
			return
		}
		if errorDetail.Valid {
			item.ErrorDetail = &errorDetail.String
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	totalPages := (total + perPage - 1) / perPage
	writeJSON(w, http.StatusOK, pushDeliveryListResponse{
		Items:      items,
		Total:      total,
		Page:       page,
		PerPage:    perPage,
		TotalPages: totalPages,
	})
}

func (s *server) handleGetPublicPushFeed(w http.ResponseWriter, r *http.Request) {
	var response pushFeedResponse
	var question string
	err := s.db.QueryRowContext(r.Context(), `
		SELECT pd.id, pd.quiz_id, q.title, q.question, pd.sent_at, pd.channel
		FROM push_deliveries pd
		INNER JOIN quizzes q ON q.id = pd.quiz_id
		WHERE pd.channel = 'mock'
		  AND pd.status = 'mock_sent'
		ORDER BY pd.sent_at DESC, pd.id DESC
		LIMIT 1
	`).Scan(
		&response.DeliveryID,
		&response.QuizID,
		&response.Title,
		&question,
		&response.SentAt,
		&response.Channel,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writePublicError(w, http.StatusNotFound, publicErrCodePushFeedNone, "mock push feed not found")
			return
		}
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, err.Error())
		return
	}
	response.Body = buildMockPushBody(question)

	writeJSON(w, http.StatusOK, response)
}
