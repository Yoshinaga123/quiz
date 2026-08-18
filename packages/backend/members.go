package main

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

const (
	memberHandleMinLen   = 3
	memberHandleMaxLen   = 32
	memberPasswordMinLen = 8
	memberPasswordMaxLen = 128
	memberBcryptCost     = 12
	memberJWTAudience    = "member"
	memberJWTTTL         = 24 * time.Hour
	pqUniqueViolation    = "23505"
)

var memberHandlePattern = regexp.MustCompile(`^[a-zA-Z0-9_]+$`)

type memberRegisterRequest struct {
	Handle   string `json:"handle"`
	Password string `json:"password"`
}

type memberRegisterResponse struct {
	ID     string `json:"id"`
	Handle string `json:"handle"`
}

type memberSessionRequest struct {
	Handle   string `json:"handle"`
	Password string `json:"password"`
}

type memberSessionResponse struct {
	Token string `json:"token"`
}

// newUUIDv7 returns an RFC 9562 UUID v7 (48-bit unix ms + 74 random bits).
func newUUIDv7() (string, error) {
	var b [16]byte
	if _, err := rand.Read(b[:]); err != nil {
		return "", err
	}
	ms := uint64(time.Now().UnixMilli())
	b[0] = byte(ms >> 40)
	b[1] = byte(ms >> 32)
	b[2] = byte(ms >> 24)
	b[3] = byte(ms >> 16)
	b[4] = byte(ms >> 8)
	b[5] = byte(ms)
	b[6] = (b[6] & 0x0f) | 0x70
	b[8] = (b[8] & 0x3f) | 0x80
	hexStr := hex.EncodeToString(b[:])
	return fmt.Sprintf("%s-%s-%s-%s-%s", hexStr[0:8], hexStr[8:12], hexStr[12:16], hexStr[16:20], hexStr[20:32]), nil
}

func validateMemberHandle(handle string) string {
	if len(handle) < memberHandleMinLen || len(handle) > memberHandleMaxLen {
		return fmt.Sprintf("handle must be %d-%d characters", memberHandleMinLen, memberHandleMaxLen)
	}
	if !memberHandlePattern.MatchString(handle) {
		return "handle must match ^[a-zA-Z0-9_]+$"
	}
	return ""
}

func validateMemberPassword(password string) string {
	if len(password) < memberPasswordMinLen || len(password) > memberPasswordMaxLen {
		return fmt.Sprintf("password must be %d-%d characters", memberPasswordMinLen, memberPasswordMaxLen)
	}
	return ""
}

func (s *server) handleRegisterMember(w http.ResponseWriter, r *http.Request) {
	var payload memberRegisterRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid registration payload")
		return
	}

	handle := strings.TrimSpace(payload.Handle)
	if msg := validateMemberHandle(handle); msg != "" {
		writeError(w, http.StatusBadRequest, msg)
		return
	}
	if msg := validateMemberPassword(payload.Password); msg != "" {
		writeError(w, http.StatusBadRequest, msg)
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(payload.Password), memberBcryptCost)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to hash password")
		return
	}

	id, err := newUUIDv7()
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to generate id")
		return
	}

	if err := s.insertMember(r.Context(), id, handle, string(hash)); err != nil {
		var pqErr *pq.Error
		if errors.As(err, &pqErr) && string(pqErr.Code) == pqUniqueViolation {
			writeError(w, http.StatusConflict, "handle already taken")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to create member")
		return
	}

	writeJSON(w, http.StatusCreated, memberRegisterResponse{ID: id, Handle: handle})
}

func (s *server) insertMember(ctx context.Context, id, handle, passwordHash string) error {
	_, err := s.db.ExecContext(
		ctx,
		`INSERT INTO members (id, handle, password_hash) VALUES ($1, $2, $3)`,
		id, handle, passwordHash,
	)
	return err
}

func (s *server) handleCreateMemberSession(w http.ResponseWriter, r *http.Request) {
	var payload memberSessionRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid login payload")
		return
	}

	handle := strings.TrimSpace(payload.Handle)
	if handle == "" || payload.Password == "" {
		writeError(w, http.StatusBadRequest, "handle and password are required")
		return
	}

	var (
		id           string
		passwordHash string
	)
	err := s.db.QueryRowContext(
		r.Context(),
		`SELECT id, password_hash FROM members WHERE handle = $1 AND deleted_at IS NULL`,
		handle,
	).Scan(&id, &passwordHash)
	if errors.Is(err, sql.ErrNoRows) {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to look up member")
		return
	}

	if bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(payload.Password)) != nil {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	token, err := s.issueMemberJWT(id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create token")
		return
	}

	writeJSON(w, http.StatusOK, memberSessionResponse{Token: token})
}

func (s *server) issueMemberJWT(memberID string) (string, error) {
	if len(s.memberJWTSecret) == 0 {
		return "", errors.New("member jwt secret is not configured")
	}
	claims := jwt.RegisteredClaims{
		Subject:   memberID,
		Audience:  jwt.ClaimStrings{memberJWTAudience},
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(memberJWTTTL)),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.memberJWTSecret)
}
