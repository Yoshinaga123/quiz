package main

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"net/mail"
	"os"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

const (
	passwordResetTokenTTL     = 30 * time.Minute
	emailVerificationTokenTTL = 24 * time.Hour
	memberEmailMaxLen         = 254
)

// Rate limits for these endpoints (ADR 0018 §5) are deferred: they need a
// generic rate_limit_events table that is not part of this PR. Short TTLs,
// SHA-256 hashed one-time tokens, and always-202 responses cover the main
// attack surface until then.

type setMemberEmailRequest struct {
	Email string `json:"email"`
}

type passwordResetRequest struct {
	HandleOrEmail string `json:"handleOrEmail"`
}

type passwordResetConsumeRequest struct {
	NewPassword string `json:"newPassword"`
}

// appBaseURL returns the URL used to build reset/verify links in outbound mail.
func appBaseURL() string {
	base := strings.TrimSpace(os.Getenv("MEMBER_APP_BASE_URL"))
	if base == "" {
		return "http://localhost:5173"
	}
	return strings.TrimRight(base, "/")
}

func generateURLToken() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func normalizeEmail(raw string) (string, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" || len(trimmed) > memberEmailMaxLen {
		return "", errors.New("email must be 1-254 characters")
	}
	addr, err := mail.ParseAddress(trimmed)
	if err != nil {
		return "", errors.New("email is not a valid RFC 5322 address")
	}
	return strings.ToLower(addr.Address), nil
}

// handleSetMemberEmail sets or changes the member's email and sends a
// verification link. The email is not treated as verified until the token in
// [handleConsumeEmailVerification] is consumed.
func (s *server) handleSetMemberEmail(w http.ResponseWriter, r *http.Request) {
	memberID, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	var payload setMemberEmailRequest
	if err := decodeJSON(r, &payload); err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "invalid payload")
		return
	}
	email, err := normalizeEmail(payload.Email)
	if err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, err.Error())
		return
	}

	tx, err := s.db.BeginTx(r.Context(), nil)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx begin failed")
		return
	}
	defer func() { _ = tx.Rollback() }()

	if _, err := tx.ExecContext(
		r.Context(),
		`UPDATE members SET email = $2, email_verified_at = NULL, updated_at = NOW()
		 WHERE id = $1 AND deleted_at IS NULL`,
		memberID, email,
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to update email")
		return
	}

	token, err := generateURLToken()
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "token gen failed")
		return
	}
	if _, err := tx.ExecContext(
		r.Context(),
		`INSERT INTO email_verification_tokens (token_hash, member_id, email, expires_at)
		 VALUES ($1, $2, $3, $4)`,
		hashToken(token), memberID, email, time.Now().Add(emailVerificationTokenTTL),
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to record verification token")
		return
	}

	if err := tx.Commit(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx commit failed")
		return
	}

	verifyURL := fmt.Sprintf("%s/verify-email?token=%s", appBaseURL(), token)
	_ = s.mailer.Send(
		r.Context(), email, "quzzes: メールアドレスの確認",
		fmt.Sprintf("以下のリンクからメールアドレスを確認してください（24時間有効）:\n%s\n", verifyURL),
	)

	w.WriteHeader(http.StatusAccepted)
}

// handleConsumeEmailVerification marks the email verified if the token matches.
func (s *server) handleConsumeEmailVerification(w http.ResponseWriter, r *http.Request) {
	token := r.PathValue("token")
	if token == "" {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "token is required")
		return
	}

	tx, err := s.db.BeginTx(r.Context(), nil)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx begin failed")
		return
	}
	defer func() { _ = tx.Rollback() }()

	var (
		memberID  string
		email     string
		expiresAt time.Time
		consumed  sql.NullTime
	)
	err = tx.QueryRowContext(
		r.Context(),
		`SELECT member_id, email, expires_at, consumed_at
		 FROM email_verification_tokens WHERE token_hash = $1`,
		hashToken(token),
	).Scan(&memberID, &email, &expiresAt, &consumed)
	if errors.Is(err, sql.ErrNoRows) || consumed.Valid || time.Now().After(expiresAt) {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "token is invalid or expired")
		return
	}
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load token")
		return
	}

	if _, err := tx.ExecContext(
		r.Context(),
		`UPDATE email_verification_tokens SET consumed_at = NOW() WHERE token_hash = $1`,
		hashToken(token),
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to consume token")
		return
	}
	if _, err := tx.ExecContext(
		r.Context(),
		`UPDATE members SET email_verified_at = NOW(), updated_at = NOW()
		 WHERE id = $1 AND email = $2 AND deleted_at IS NULL`,
		memberID, email,
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to mark verified")
		return
	}

	if err := tx.Commit(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx commit failed")
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// handleRequestPasswordReset always returns 202 Accepted (ADR 0018 §3) to
// avoid handle/email enumeration. When a matching verified email exists the
// reset link is dispatched via the mailer.
func (s *server) handleRequestPasswordReset(w http.ResponseWriter, r *http.Request) {
	var payload passwordResetRequest
	if err := decodeJSON(r, &payload); err != nil {
		// Same 202 to keep responses uniform even for garbled bodies.
		w.WriteHeader(http.StatusAccepted)
		return
	}

	key := strings.TrimSpace(payload.HandleOrEmail)
	if key == "" {
		w.WriteHeader(http.StatusAccepted)
		return
	}

	var (
		memberID string
		email    sql.NullString
	)
	err := s.db.QueryRowContext(
		r.Context(),
		`SELECT id, email FROM members
		 WHERE deleted_at IS NULL
		   AND email_verified_at IS NOT NULL
		   AND (handle = $1 OR email = $1)
		 LIMIT 1`,
		key,
	).Scan(&memberID, &email)
	if err != nil || !email.Valid {
		// Timing: sleep a bit so found vs not-found paths are similar.
		time.Sleep(50 * time.Millisecond)
		w.WriteHeader(http.StatusAccepted)
		return
	}

	token, tokErr := generateURLToken()
	if tokErr != nil {
		w.WriteHeader(http.StatusAccepted)
		return
	}
	if _, err := s.db.ExecContext(
		r.Context(),
		`INSERT INTO password_reset_tokens (token_hash, member_id, expires_at) VALUES ($1, $2, $3)`,
		hashToken(token), memberID, time.Now().Add(passwordResetTokenTTL),
	); err != nil {
		w.WriteHeader(http.StatusAccepted)
		return
	}

	resetURL := fmt.Sprintf("%s/reset-password?token=%s", appBaseURL(), token)
	_ = s.mailer.Send(
		r.Context(), email.String, "quzzes: パスワード再設定",
		fmt.Sprintf("以下のリンクから新しいパスワードを設定してください（30分有効）:\n%s\n", resetURL),
	)
	w.WriteHeader(http.StatusAccepted)
}

// handleConsumePasswordReset consumes a reset token and rewrites the hash.
func (s *server) handleConsumePasswordReset(w http.ResponseWriter, r *http.Request) {
	token := r.PathValue("token")
	if token == "" {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "token is required")
		return
	}

	var payload passwordResetConsumeRequest
	if err := decodeJSON(r, &payload); err != nil {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "invalid payload")
		return
	}
	if msg := validateMemberPassword(payload.NewPassword); msg != "" {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, msg)
		return
	}

	tx, err := s.db.BeginTx(r.Context(), nil)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx begin failed")
		return
	}
	defer func() { _ = tx.Rollback() }()

	var (
		memberID  string
		expiresAt time.Time
		consumed  sql.NullTime
	)
	err = tx.QueryRowContext(
		r.Context(),
		`SELECT member_id, expires_at, consumed_at FROM password_reset_tokens WHERE token_hash = $1`,
		hashToken(token),
	).Scan(&memberID, &expiresAt, &consumed)
	if errors.Is(err, sql.ErrNoRows) || consumed.Valid || time.Now().After(expiresAt) {
		writePublicError(w, http.StatusBadRequest, publicErrCodeBadRequest, "token is invalid or expired")
		return
	}
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load token")
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(payload.NewPassword), memberBcryptCost)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "hash failed")
		return
	}

	if _, err := tx.ExecContext(
		r.Context(),
		`UPDATE members SET password_hash = $2, updated_at = NOW()
		 WHERE id = $1 AND deleted_at IS NULL`,
		memberID, string(hash),
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to update password")
		return
	}
	// Prevent multi-use: mark token consumed and invalidate all pending tokens for this member.
	if _, err := tx.ExecContext(
		r.Context(),
		`UPDATE password_reset_tokens SET consumed_at = NOW()
		 WHERE member_id = $1 AND consumed_at IS NULL`,
		memberID,
	); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to consume token")
		return
	}

	if err := tx.Commit(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "tx commit failed")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// contextWithMemberID is exposed for tests to synthesize a member auth context.
func contextWithMemberID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, ctxKeyMemberID, id)
}
