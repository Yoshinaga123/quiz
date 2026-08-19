package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestLoginVerificationCodeExposureDependsOnEnvironment(t *testing.T) {
	for _, test := range []struct {
		name     string
		appEnv   string
		wantCode bool
	}{
		{name: "development returns code", appEnv: "development", wantCode: true},
		{name: "production omits code", appEnv: "production", wantCode: false},
	} {
		t.Run(test.name, func(t *testing.T) {
			t.Setenv("APP_ENV", test.appEnv)
			s := &server{
				adminUser:            "admin",
				adminPassword:        "strong-password",
				pendingVerifications: make(map[string]verificationChallenge),
			}
			req := httptest.NewRequest(
				http.MethodPost,
				"/api/admin/login/verification",
				strings.NewReader(`{"username":"admin","password":"strong-password"}`),
			)
			recorder := httptest.NewRecorder()

			s.handleRequestLoginVerification(recorder, req)

			if recorder.Code != http.StatusOK {
				t.Fatalf("status = %d, want %d: %s", recorder.Code, http.StatusOK, recorder.Body.String())
			}
			var response verificationResponse
			if err := json.Unmarshal(recorder.Body.Bytes(), &response); err != nil {
				t.Fatalf("decode response: %v", err)
			}
			if response.ChallengeID == "" {
				t.Fatal("challengeId must not be empty")
			}
			if (response.Code != "") != test.wantCode {
				t.Fatalf("code present = %t, want %t", response.Code != "", test.wantCode)
			}
		})
	}
}
