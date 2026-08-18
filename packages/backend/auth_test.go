package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func newAuthTestServer() *server {
	return &server{
		adminUser:              "admin",
		adminPassword:          "password",
		jwtSecret:              []byte("test-secret"),
		pendingVerifications:   make(map[string]verificationChallenge),
		returnVerificationCode: false,
	}
}

func TestIsDevelopmentMode(t *testing.T) {
	t.Setenv("APP_ENV", "")
	if isDevelopmentMode() {
		t.Fatal("empty APP_ENV must not be development")
	}

	t.Setenv("APP_ENV", "production")
	if isDevelopmentMode() {
		t.Fatal("production must not return verification codes")
	}

	t.Setenv("APP_ENV", "development")
	if !isDevelopmentMode() {
		t.Fatal("APP_ENV=development must be development mode")
	}

	t.Setenv("APP_ENV", "DEV")
	if !isDevelopmentMode() {
		t.Fatal("APP_ENV=dev must be development mode")
	}
}

func TestHandleRequestLoginVerificationOmitsCodeOutsideDevelopment(t *testing.T) {
	s := newAuthTestServer()

	req := httptest.NewRequest(http.MethodPost, "/api/admin/login/verification", strings.NewReader(
		`{"username":"admin","password":"password"}`,
	))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body verificationResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.ChallengeID == "" || body.Message == "" {
		t.Fatalf("expected challenge response, got %+v", body)
	}
	if body.Code != "" {
		t.Fatalf("production response must omit verification code, got %q", body.Code)
	}
}

func TestHandleRequestLoginVerificationReturnsCodeInDevelopment(t *testing.T) {
	s := newAuthTestServer()
	s.returnVerificationCode = true

	req := httptest.NewRequest(http.MethodPost, "/api/admin/login/verification", strings.NewReader(
		`{"username":"admin","password":"password"}`,
	))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()

	s.routes().ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var body verificationResponse
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if body.Code == "" {
		t.Fatal("development response must include the verification code")
	}
}
