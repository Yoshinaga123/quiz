package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestWithCORSReflectsOriginWhenAllowlistEmpty(t *testing.T) {
	t.Setenv("CORS_ALLOWED_ORIGINS", "")

	handler := withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	req.Header.Set("Origin", "http://localhost:5174")
	res := httptest.NewRecorder()
	handler.ServeHTTP(res, req)

	if got := res.Header().Get("Access-Control-Allow-Origin"); got != "http://localhost:5174" {
		t.Fatalf("Allow-Origin = %q", got)
	}
}

func TestWithCORSAllowlistRejectsUnknownOrigin(t *testing.T) {
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://socrates-quiz.jp")

	handler := withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	req.Header.Set("Origin", "https://evil.example")
	res := httptest.NewRecorder()
	handler.ServeHTTP(res, req)

	if got := res.Header().Get("Access-Control-Allow-Origin"); got != "" {
		t.Fatalf("expected empty Allow-Origin, got %q", got)
	}
}

func TestWithCORSAllowlistAcceptsListedOrigin(t *testing.T) {
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://socrates-quiz.jp, https://www.socrates-quiz.jp")

	handler := withCORS(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	req := httptest.NewRequest(http.MethodOptions, "/v1/quizzes", nil)
	req.Header.Set("Origin", "https://socrates-quiz.jp")
	res := httptest.NewRecorder()
	handler.ServeHTTP(res, req)

	if res.Code != http.StatusNoContent {
		t.Fatalf("status = %d", res.Code)
	}
	if got := res.Header().Get("Access-Control-Allow-Origin"); got != "https://socrates-quiz.jp" {
		t.Fatalf("Allow-Origin = %q", got)
	}
}
