package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"regexp"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/golang-jwt/jwt/v5"
	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

const (
	memberTestHandle   = "quiztaker_01"
	memberTestPassword = "correcthorse"
	memberTestSecret   = "test-member-secret"
	memberTestID       = "0192b6f7-4c50-73b1-8b71-11223344aabb"
)

func newMockMemberServer(t *testing.T) (*server, sqlmock.Sqlmock, func()) {
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
		memberJWTSecret:      []byte(memberTestSecret),
		pendingVerifications: make(map[string]verificationChallenge),
	}

	return s, mock, func() {
		if err := mock.ExpectationsWereMet(); err != nil {
			t.Fatalf("unmet sql expectations: %v", err)
		}
		_ = db.Close()
	}
}

func doJSON(s *server, method, path, body string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	return res
}

func TestNewUUIDv7Format(t *testing.T) {
	pattern := regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`)
	for i := 0; i < 32; i++ {
		id, err := newUUIDv7()
		if err != nil {
			t.Fatalf("newUUIDv7: %v", err)
		}
		if !pattern.MatchString(id) {
			t.Fatalf("id %q does not look like UUID v7", id)
		}
	}
}

func TestHandleRegisterMemberSuccess(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	mock.ExpectExec(regexp.QuoteMeta(`INSERT INTO members (id, handle, password_hash) VALUES ($1, $2, $3)`)).
		WithArgs(sqlmock.AnyArg(), memberTestHandle, sqlmock.AnyArg()).
		WillReturnResult(sqlmock.NewResult(0, 1))

	body := `{"handle":"` + memberTestHandle + `","password":"` + memberTestPassword + `"}`
	res := doJSON(s, http.MethodPost, "/api/members", body)

	if res.Code != http.StatusCreated {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var out memberRegisterResponse
	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if out.Handle != memberTestHandle {
		t.Fatalf("handle = %q", out.Handle)
	}
	if out.ID == "" {
		t.Fatalf("id is empty")
	}
}

func TestHandleRegisterMemberDuplicateHandle(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	mock.ExpectExec(regexp.QuoteMeta(`INSERT INTO members (id, handle, password_hash) VALUES ($1, $2, $3)`)).
		WithArgs(sqlmock.AnyArg(), memberTestHandle, sqlmock.AnyArg()).
		WillReturnError(&pq.Error{Code: pqUniqueViolation})

	body := `{"handle":"` + memberTestHandle + `","password":"` + memberTestPassword + `"}`
	res := doJSON(s, http.MethodPost, "/api/members", body)

	if res.Code != http.StatusConflict {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleRegisterMemberRejectsShortPassword(t *testing.T) {
	s, _, cleanup := newMockMemberServer(t)
	defer cleanup()

	body := `{"handle":"` + memberTestHandle + `","password":"short"}`
	res := doJSON(s, http.MethodPost, "/api/members", body)

	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleRegisterMemberRejectsBadHandle(t *testing.T) {
	s, _, cleanup := newMockMemberServer(t)
	defer cleanup()

	cases := []struct {
		name   string
		handle string
	}{
		{"too short", "ab"},
		{"illegal char", "user name"},
		{"hyphen not allowed", "user-name"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			body := `{"handle":"` + tc.handle + `","password":"` + memberTestPassword + `"}`
			res := doJSON(s, http.MethodPost, "/api/members", body)
			if res.Code != http.StatusBadRequest {
				t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
			}
		})
	}
}

func TestHandleCreateMemberSessionSuccess(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	hash, err := bcrypt.GenerateFromPassword([]byte(memberTestPassword), bcrypt.MinCost)
	if err != nil {
		t.Fatalf("hash: %v", err)
	}

	mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, password_hash FROM members WHERE handle = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestHandle).
		WillReturnRows(sqlmock.NewRows([]string{"id", "password_hash"}).AddRow(memberTestID, string(hash)))

	body := `{"handle":"` + memberTestHandle + `","password":"` + memberTestPassword + `"}`
	res := doJSON(s, http.MethodPost, "/api/session", body)

	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var out memberSessionResponse
	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		t.Fatalf("decode: %v", err)
	}

	claims := &jwt.RegisteredClaims{}
	token, err := jwt.ParseWithClaims(out.Token, claims, func(*jwt.Token) (any, error) {
		return []byte(memberTestSecret), nil
	})
	if err != nil || !token.Valid {
		t.Fatalf("token parse: err=%v valid=%v", err, token != nil && token.Valid)
	}
	if claims.Subject != memberTestID {
		t.Fatalf("subject = %q", claims.Subject)
	}
	if len(claims.Audience) != 1 || claims.Audience[0] != memberJWTAudience {
		t.Fatalf("audience = %v", claims.Audience)
	}
}

func TestHandleCreateMemberSessionRejectsWrongPassword(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	hash, err := bcrypt.GenerateFromPassword([]byte(memberTestPassword), bcrypt.MinCost)
	if err != nil {
		t.Fatalf("hash: %v", err)
	}

	mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, password_hash FROM members WHERE handle = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestHandle).
		WillReturnRows(sqlmock.NewRows([]string{"id", "password_hash"}).AddRow(memberTestID, string(hash)))

	body := `{"handle":"` + memberTestHandle + `","password":"wrong-password"}`
	res := doJSON(s, http.MethodPost, "/api/session", body)

	if res.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleCreateMemberSessionRejectsDeletedMember(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	// The `WHERE deleted_at IS NULL` filter turns a soft-deleted lookup into ErrNoRows.
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT id, password_hash FROM members WHERE handle = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestHandle).
		WillReturnRows(sqlmock.NewRows([]string{"id", "password_hash"}))

	body := `{"handle":"` + memberTestHandle + `","password":"` + memberTestPassword + `"}`
	res := doJSON(s, http.MethodPost, "/api/session", body)

	if res.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestIssueMemberJWTUsesSeparateSecret(t *testing.T) {
	s := &server{
		jwtSecret:       []byte("admin-secret"),
		memberJWTSecret: []byte(memberTestSecret),
	}

	token, err := s.issueMemberJWT(memberTestID)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}

	// Token signed with member secret must NOT verify against the admin secret.
	if _, err := jwt.Parse(token, func(*jwt.Token) (any, error) {
		return s.jwtSecret, nil
	}); err == nil {
		t.Fatalf("member token unexpectedly verified against admin secret")
	}

	claims := &jwt.RegisteredClaims{}
	parsed, err := jwt.ParseWithClaims(token, claims, func(*jwt.Token) (any, error) {
		return s.memberJWTSecret, nil
	})
	if err != nil || !parsed.Valid {
		t.Fatalf("member token failed to verify with member secret: %v", err)
	}
}
