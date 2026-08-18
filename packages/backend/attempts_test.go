package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/lib/pq"
)

const attemptSessionID = "550e8400-e29b-41d4-a716-446655440000"

func newMockAttemptTestServer(t *testing.T) (*server, sqlmock.Sqlmock, func()) {
	t.Helper()

	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New: %v", err)
	}

	s := &server{
		db:                   db,
		adminUser:            "admin",
		adminPassword:        "password",
		jwtSecret:            []byte("test-secret"),
		pendingVerifications: make(map[string]verificationChallenge),
	}

	return s, mock, func() {
		if err := mock.ExpectationsWereMet(); err != nil {
			t.Fatalf("unmet sql expectations: %v", err)
		}
		_ = db.Close()
	}
}

func postAttempt(s *server, body string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodPost, "/v1/attempts", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	return res
}

func validAttemptBody() string {
	return `{
		"clientSessionId": "` + attemptSessionID + `",
		"completedAt": "2026-01-15T10:30:00.000Z",
		"section": "React",
		"answers": [
			{"quizId": 1, "selectedIndex": 0, "isCorrect": true}
		]
	}`
}

func TestHandleSubmitAttemptCreatesRows(t *testing.T) {
	s, mock, cleanup := newMockAttemptTestServer(t)
	defer cleanup()

	completedAt := time.Date(2026, 1, 15, 10, 30, 0, 0, time.UTC)

	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT COUNT(DISTINCT id) FROM quizzes WHERE id = ANY($1)`)).
		WithArgs(pq.Array([]int64{1})).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))
	mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO attempts`)).
		WithArgs(attemptSessionID, "React", completedAt, 1, 1).
		WillReturnRows(sqlmock.NewRows([]string{"client_session_id"}).AddRow(attemptSessionID))
	mock.ExpectExec(regexp.QuoteMeta(`INSERT INTO attempt_answers`)).
		WithArgs(attemptSessionID, int64(1), 0, true, nil).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	res := postAttempt(s, validAttemptBody())
	if res.Code != http.StatusAccepted {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body attemptAccepted
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.ClientSessionID != attemptSessionID || body.Status != attemptAcceptedStatus {
		t.Fatalf("unexpected response: %+v", body)
	}
}

func TestHandleSubmitAttemptIsIdempotent(t *testing.T) {
	s, mock, cleanup := newMockAttemptTestServer(t)
	defer cleanup()

	completedAt := time.Date(2026, 1, 15, 10, 30, 0, 0, time.UTC)

	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT COUNT(DISTINCT id) FROM quizzes WHERE id = ANY($1)`)).
		WithArgs(pq.Array([]int64{1})).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))
	mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO attempts`)).
		WithArgs(attemptSessionID, "React", completedAt, 1, 1).
		WillReturnRows(sqlmock.NewRows([]string{"client_session_id"}))
	mock.ExpectCommit()

	res := postAttempt(s, validAttemptBody())
	if res.Code != http.StatusAccepted {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleSubmitAttemptRejectsEmptyAnswers(t *testing.T) {
	s, mock, cleanup := newMockAttemptTestServer(t)
	defer cleanup()

	res := postAttempt(s, `{
		"clientSessionId": "`+attemptSessionID+`",
		"completedAt": "2026-01-15T10:30:00.000Z",
		"answers": []
	}`)
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unexpected queries: %v", err)
	}
}

func TestHandleSubmitAttemptRejectsInvalidUUID(t *testing.T) {
	s, mock, cleanup := newMockAttemptTestServer(t)
	defer cleanup()

	res := postAttempt(s, `{
		"clientSessionId": "not-a-uuid",
		"completedAt": "2026-01-15T10:30:00.000Z",
		"answers": [{"quizId": 1, "selectedIndex": 0, "isCorrect": true}]
	}`)
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unexpected queries: %v", err)
	}
}
