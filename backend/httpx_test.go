package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestParseID(t *testing.T) {
	if _, err := parseID("0"); err == nil {
		t.Fatal("expected error for non-positive id")
	}
	if _, err := parseID("abc"); err == nil {
		t.Fatal("expected error for non-numeric id")
	}

	id, err := parseID("12")
	if err != nil {
		t.Fatalf("parseID(12): %v", err)
	}
	if id != 12 {
		t.Fatalf("parseID(12)=%d", id)
	}
}

func TestNormalizeQuizPayload(t *testing.T) {
	payload := quizPayload{
		Section:            "  React  ",
		Title:              "useState",
		Question:           "What does useState return?",
		Explanation:        "A state tuple.",
		Source:             "https://react.dev",
		Status:             "published",
		Options:            []string{"  array  ", "object"},
		CorrectAnswerIndex: 0,
	}
	if err := normalizeQuizPayload(&payload); err != nil {
		t.Fatalf("normalizeQuizPayload: %v", err)
	}
	if payload.Section != "React" || payload.Options[0] != "array" {
		t.Fatalf("unexpected normalized payload: %+v", payload)
	}

	payload.CorrectAnswerIndex = 9
	if err := normalizeQuizPayload(&payload); err == nil {
		t.Fatal("expected out-of-range correctAnswerIndex")
	}
}

func TestHealthz(t *testing.T) {
	s := &server{pendingVerifications: map[string]verificationChallenge{}}
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	s.routes().ServeHTTP(rec, req)
	if rec.Code != http.StatusOK || rec.Body.String() != "ok" {
		t.Fatalf("healthz: status=%d body=%q", rec.Code, rec.Body.String())
	}
}

func TestAdminQuizzesRequiresAuth(t *testing.T) {
	s := &server{
		jwtSecret:            []byte("test-secret"),
		pendingVerifications: map[string]verificationChallenge{},
	}
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/admin/quizzes", nil)
	s.routes().ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", rec.Code)
	}
}

func TestCORSPreflightReflectsOrigin(t *testing.T) {
	s := &server{pendingVerifications: map[string]verificationChallenge{}}
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodOptions, "/v1/quizzes", nil)
	req.Header.Set("Origin", "http://localhost:5174")
	s.routes().ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("preflight status=%d", rec.Code)
	}
	if got := rec.Header().Get("Access-Control-Allow-Origin"); got != "http://localhost:5174" {
		t.Fatalf("Allow-Origin=%q", got)
	}
}

func TestRequireAuthAcceptsIssuedJWT(t *testing.T) {
	s := &server{
		adminUser:            "admin",
		jwtSecret:            []byte("test-secret"),
		pendingVerifications: map[string]verificationChallenge{},
	}
	handler := s.requireAuth(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("missing token: status=%d", rec.Code)
	}

	token, err := s.issueJWT()
	if err != nil {
		t.Fatalf("issueJWT: %v", err)
	}

	rec = httptest.NewRecorder()
	req = httptest.NewRequest(http.MethodGet, "/", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	handler.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("valid token: status=%d body=%s", rec.Code, rec.Body.String())
	}
}

func TestDecodeJSONRejectsUnknownFields(t *testing.T) {
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(`{"username":"a","extra":true}`))
	var dst struct {
		Username string `json:"username"`
	}
	if err := decodeJSON(req, &dst); err == nil {
		t.Fatal("expected unknown field error")
	}
}
