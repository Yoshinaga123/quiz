package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

func newMockPushTestServer(t *testing.T) (*server, sqlmock.Sqlmock, func()) {
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

func TestHandleDispatchMockPushCreatesDelivery(t *testing.T) {
	s, mock, cleanup := newMockPushTestServer(t)
	defer cleanup()

	sentAt := time.Date(2026, 5, 25, 2, 0, 0, 0, time.UTC)
	mock.ExpectQuery(regexp.QuoteMeta("SELECT id, title, question")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "title", "question"}).
			AddRow(int64(42), "Go の defer", "defer はいつ実行されますか？"))
	mock.ExpectQuery(regexp.QuoteMeta("INSERT INTO push_deliveries")).
		WithArgs(int64(42), "mock", 0, "mock_sent").
		WillReturnRows(sqlmock.NewRows([]string{
			"id",
			"quiz_id",
			"channel",
			"target_count",
			"status",
			"sent_at",
		}).AddRow(int64(1001), int64(42), "mock", 0, "mock_sent", sentAt))

	token, err := s.issueJWT()
	if err != nil {
		t.Fatalf("issueJWT: %v", err)
	}

	req := httptest.NewRequest(http.MethodPost, "/api/admin/push/dispatch", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusCreated {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body pushDispatchResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.DeliveryID != 1001 || body.QuizID != 42 || body.Title != "Go の defer" {
		t.Fatalf("unexpected response: %+v", body)
	}
	if body.Channel != "mock" || body.TargetCount != 0 || body.Status != "mock_sent" {
		t.Fatalf("unexpected delivery metadata: %+v", body)
	}
}

func TestHandleDispatchMockPushReturns422WithoutCandidate(t *testing.T) {
	s, mock, cleanup := newMockPushTestServer(t)
	defer cleanup()

	mock.ExpectQuery(regexp.QuoteMeta("SELECT id, title, question")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "title", "question"}))

	token, err := s.issueJWT()
	if err != nil {
		t.Fatalf("issueJWT: %v", err)
	}

	req := httptest.NewRequest(http.MethodPost, "/api/admin/push/dispatch", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusUnprocessableEntity {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body errorResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Code != "no_push_candidates" {
		t.Fatalf("code = %q, body = %+v", body.Code, body)
	}
}

func TestHandleGetPublicPushFeedReturnsLatestMockDelivery(t *testing.T) {
	s, mock, cleanup := newMockPushTestServer(t)
	defer cleanup()

	sentAt := time.Date(2026, 5, 25, 2, 5, 0, 0, time.UTC)
	mock.ExpectQuery(regexp.QuoteMeta("SELECT pd.id, pd.quiz_id, q.title, q.question, pd.sent_at, pd.channel")).
		WillReturnRows(sqlmock.NewRows([]string{
			"delivery_id",
			"quiz_id",
			"title",
			"question",
			"sent_at",
			"channel",
		}).AddRow(int64(1001), int64(42), "Go の defer", "defer はいつ実行されますか？", sentAt, "mock"))

	req := httptest.NewRequest(http.MethodGet, "/v1/push/feed", nil)
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body pushFeedResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.DeliveryID != 1001 || body.QuizID != 42 || body.Title != "Go の defer" {
		t.Fatalf("unexpected response: %+v", body)
	}
	if body.Body != "defer はいつ実行されますか？" || body.Channel != "mock" {
		t.Fatalf("unexpected feed metadata: %+v", body)
	}
}

func TestHandleGetPublicPushFeedSkipsUnpublishedQuizzes(t *testing.T) {
	s, mock, cleanup := newMockPushTestServer(t)
	defer cleanup()

	mock.ExpectQuery(regexp.QuoteMeta("AND q.status = 'published'")).
		WillReturnRows(sqlmock.NewRows([]string{
			"delivery_id",
			"quiz_id",
			"title",
			"question",
			"sent_at",
			"channel",
		}))

	req := httptest.NewRequest(http.MethodGet, "/v1/push/feed", nil)
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusNotFound {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body publicErrorResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Code != publicErrCodePushFeedNone {
		t.Fatalf("code = %q, body = %+v", body.Code, body)
	}
}

func TestHandleListPushDeliveriesReturnsPaginatedHistory(t *testing.T) {
	s, mock, cleanup := newMockPushTestServer(t)
	defer cleanup()

	sentAt := time.Date(2026, 5, 25, 2, 10, 0, 0, time.UTC)
	mock.ExpectQuery(regexp.QuoteMeta("SELECT COUNT(*) FROM push_deliveries")).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))
	mock.ExpectQuery(regexp.QuoteMeta("SELECT pd.id, pd.quiz_id, q.title")).
		WithArgs(20, 0).
		WillReturnRows(sqlmock.NewRows([]string{
			"id",
			"quiz_id",
			"title",
			"channel",
			"target_count",
			"status",
			"error_detail",
			"sent_at",
		}).AddRow(int64(1001), int64(42), "Go の defer", "mock", 0, "mock_sent", nil, sentAt))

	token, err := s.issueJWT()
	if err != nil {
		t.Fatalf("issueJWT: %v", err)
	}

	req := httptest.NewRequest(http.MethodGet, "/api/admin/push/deliveries", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body pushDeliveryListResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Total != 1 || body.Page != 1 || body.PerPage != 20 || body.TotalPages != 1 {
		t.Fatalf("unexpected pagination: %+v", body)
	}
	if len(body.Items) != 1 || body.Items[0].DeliveryID != 1001 || body.Items[0].Title != "Go の defer" {
		t.Fatalf("unexpected items: %+v", body.Items)
	}
}
