package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"golang.org/x/crypto/bcrypt"
)

type recorderMailer struct {
	Sent []struct{ To, Subject, Body string }
}

func (m *recorderMailer) Send(_ context.Context, to, subject, body string) error {
	m.Sent = append(m.Sent, struct{ To, Subject, Body string }{to, subject, body})
	return nil
}

func newMockMemberServerWithMailer(t *testing.T) (*server, sqlmock.Sqlmock, *recorderMailer, func()) {
	t.Helper()
	s, mock, cleanup := newMockMemberServer(t)
	mailer := &recorderMailer{}
	s.mailer = mailer
	return s, mock, mailer, cleanup
}

func TestNormalizeEmail(t *testing.T) {
	cases := []struct {
		in, want string
		wantErr  bool
	}{
		{"user@example.com", "user@example.com", false},
		{"  USER@EXAMPLE.com ", "user@example.com", false},
		{"", "", true},
		{"not-an-email", "", true},
		{strings.Repeat("a", 255) + "@x.com", "", true},
	}
	for _, tc := range cases {
		got, err := normalizeEmail(tc.in)
		if tc.wantErr && err == nil {
			t.Errorf("normalizeEmail(%q) expected error", tc.in)
		}
		if !tc.wantErr && err != nil {
			t.Errorf("normalizeEmail(%q) unexpected error: %v", tc.in, err)
		}
		if !tc.wantErr && got != tc.want {
			t.Errorf("normalizeEmail(%q) = %q, want %q", tc.in, got, tc.want)
		}
	}
}

func TestHashTokenIsDeterministicAndDifferentFromInput(t *testing.T) {
	tok, err := generateURLToken()
	if err != nil {
		t.Fatalf("generate: %v", err)
	}
	if len(tok) != 64 {
		t.Fatalf("url token should be 32 bytes hex (64 chars), got %d", len(tok))
	}
	h1 := hashToken(tok)
	h2 := hashToken(tok)
	if h1 != h2 {
		t.Fatalf("hashToken not deterministic")
	}
	if h1 == tok {
		t.Fatalf("hash equals plaintext")
	}
	if len(h1) != 64 {
		t.Fatalf("sha256 hex should be 64 chars, got %d", len(h1))
	}
}

func TestHandleSetMemberEmailSendsVerificationLink(t *testing.T) {
	s, mock, mailer, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectBegin()
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE members SET email = $2, email_verified_at = NULL`)).
		WithArgs(memberTestID, "user@example.com").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(regexp.QuoteMeta(`INSERT INTO email_verification_tokens`)).
		WithArgs(sqlmock.AnyArg(), memberTestID, "user@example.com", sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	res := doAuth(s, http.MethodPost, "/api/me/email", `{"email":"user@example.com"}`, meBearer(t, s))
	if res.Code != http.StatusAccepted {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	if len(mailer.Sent) != 1 || mailer.Sent[0].To != "user@example.com" {
		t.Fatalf("mail not dispatched: %+v", mailer.Sent)
	}
	if !strings.Contains(mailer.Sent[0].Body, "/verify-email?token=") {
		t.Fatalf("mail body missing verification link: %q", mailer.Sent[0].Body)
	}
}

func TestHandleConsumeEmailVerificationMarksVerified(t *testing.T) {
	s, mock, _, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	token := "aabbccddeeff"
	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT member_id, email, expires_at, consumed_at FROM email_verification_tokens WHERE token_hash = $1`)).
		WithArgs(hashToken(token)).
		WillReturnRows(sqlmock.NewRows([]string{"member_id", "email", "expires_at", "consumed_at"}).
			AddRow(memberTestID, "user@example.com", time.Now().Add(time.Hour), nil))
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE email_verification_tokens SET consumed_at`)).
		WithArgs(hashToken(token)).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE members SET email_verified_at = NOW()`)).
		WithArgs(memberTestID, "user@example.com").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	req := httptest.NewRequest(http.MethodPost, "/api/email-verifications/"+token, nil)
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	if res.Code != http.StatusNoContent {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleConsumeEmailVerificationRejectsExpired(t *testing.T) {
	s, mock, _, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	token := "expired-token"
	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT member_id, email, expires_at, consumed_at FROM email_verification_tokens WHERE token_hash = $1`)).
		WithArgs(hashToken(token)).
		WillReturnRows(sqlmock.NewRows([]string{"member_id", "email", "expires_at", "consumed_at"}).
			AddRow(memberTestID, "user@example.com", time.Now().Add(-time.Hour), nil))

	req := httptest.NewRequest(http.MethodPost, "/api/email-verifications/"+token, nil)
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d", res.Code)
	}
}

func TestHandleRequestPasswordResetAlwaysReturns202(t *testing.T) {
	s, mock, mailer, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	// Unknown handle -> ErrNoRows-style empty result.
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, email FROM members`)).
		WithArgs("ghost").
		WillReturnRows(sqlmock.NewRows([]string{"id", "email"}))

	res := doJSON(s, http.MethodPost, "/api/password-resets", `{"handleOrEmail":"ghost"}`)
	if res.Code != http.StatusAccepted {
		t.Fatalf("status = %d", res.Code)
	}
	if len(mailer.Sent) != 0 {
		t.Fatalf("mail should not be sent when member is unknown")
	}
}

func TestHandleRequestPasswordResetSendsWhenKnownAndVerified(t *testing.T) {
	s, mock, mailer, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, email FROM members`)).
		WithArgs(memberTestHandle).
		WillReturnRows(sqlmock.NewRows([]string{"id", "email"}).AddRow(memberTestID, "user@example.com"))
	mock.ExpectExec(regexp.QuoteMeta(`INSERT INTO password_reset_tokens`)).
		WithArgs(sqlmock.AnyArg(), memberTestID, sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))

	res := doJSON(s, http.MethodPost, "/api/password-resets", `{"handleOrEmail":"`+memberTestHandle+`"}`)
	if res.Code != http.StatusAccepted {
		t.Fatalf("status = %d", res.Code)
	}
	if len(mailer.Sent) != 1 {
		t.Fatalf("expected one mail; got %d", len(mailer.Sent))
	}
	if !strings.Contains(mailer.Sent[0].Body, "/reset-password?token=") {
		t.Fatalf("mail body missing reset link: %q", mailer.Sent[0].Body)
	}
}

func TestHandleConsumePasswordResetRewritesHash(t *testing.T) {
	s, mock, _, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	token := "reset-token"
	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT member_id, expires_at, consumed_at FROM password_reset_tokens WHERE token_hash = $1`)).
		WithArgs(hashToken(token)).
		WillReturnRows(sqlmock.NewRows([]string{"member_id", "expires_at", "consumed_at"}).
			AddRow(memberTestID, time.Now().Add(time.Hour), nil))
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE members SET password_hash`)).
		WithArgs(memberTestID, sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE password_reset_tokens SET consumed_at`)).
		WithArgs(memberTestID).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	req := httptest.NewRequest(http.MethodPost, "/api/password-resets/"+token,
		strings.NewReader(`{"newPassword":"brand-new-password"}`))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	if res.Code != http.StatusNoContent {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleConsumePasswordResetRejectsShortPassword(t *testing.T) {
	s, _, _, cleanup := newMockMemberServerWithMailer(t)
	defer cleanup()

	req := httptest.NewRequest(http.MethodPost, "/api/password-resets/some-token",
		strings.NewReader(`{"newPassword":"short"}`))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d", res.Code)
	}
}

// _ silences the unused import warning when a mailer field is set via a fake bcrypt call
var _ = bcrypt.MinCost
