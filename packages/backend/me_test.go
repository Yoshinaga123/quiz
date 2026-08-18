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
	"github.com/golang-jwt/jwt/v5"
)

func meBearer(t *testing.T, s *server) string {
	t.Helper()
	token, err := s.issueMemberJWT(memberTestID)
	if err != nil {
		t.Fatalf("issueMemberJWT: %v", err)
	}
	return "Bearer " + token
}

func meAdminBearer(t *testing.T, s *server) string {
	t.Helper()
	claims := jwt.RegisteredClaims{
		Subject:   "admin",
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
	}
	tok, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(s.jwtSecret)
	if err != nil {
		t.Fatalf("admin token: %v", err)
	}
	return "Bearer " + tok
}

func doAuth(s *server, method, path, body, bearer string) *httptest.ResponseRecorder {
	var reader *strings.Reader
	if body == "" {
		reader = strings.NewReader("")
	} else {
		reader = strings.NewReader(body)
	}
	req := httptest.NewRequest(method, path, reader)
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	if bearer != "" {
		req.Header.Set("Authorization", bearer)
	}
	res := httptest.NewRecorder()
	s.routes().ServeHTTP(res, req)
	return res
}

func expectActiveMemberLookup(mock sqlmock.Sqlmock) {
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT deleted_at FROM members WHERE id = $1`)).
		WithArgs(memberTestID).
		WillReturnRows(sqlmock.NewRows([]string{"deleted_at"}).AddRow(nil))
}

func TestRequireMemberAuthRejectsMissingHeader(t *testing.T) {
	s, _, cleanup := newMockMemberServer(t)
	defer cleanup()

	res := doAuth(s, http.MethodGet, "/api/me", "", "")
	if res.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d", res.Code)
	}
}

func TestRequireMemberAuthRejectsAdminToken(t *testing.T) {
	s, _, cleanup := newMockMemberServer(t)
	defer cleanup()

	res := doAuth(s, http.MethodGet, "/api/me", "", meAdminBearer(t, s))
	if res.Code != http.StatusUnauthorized {
		t.Fatalf("admin token accepted on /api/me: status = %d", res.Code)
	}
}

func TestRequireMemberAuthRejectsSoftDeletedMember(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	mock.ExpectQuery(regexp.QuoteMeta(`SELECT deleted_at FROM members WHERE id = $1`)).
		WithArgs(memberTestID).
		WillReturnRows(sqlmock.NewRows([]string{"deleted_at"}).AddRow(time.Now()))

	res := doAuth(s, http.MethodGet, "/api/me", "", meBearer(t, s))
	if res.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleGetMe(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT handle, email_verified_at FROM members WHERE id = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestID).
		WillReturnRows(sqlmock.NewRows([]string{"handle", "email_verified_at"}).AddRow(memberTestHandle, nil))

	res := doAuth(s, http.MethodGet, "/api/me", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got publicMember
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.ID != memberTestID || got.Handle != memberTestHandle {
		t.Fatalf("got = %+v", got)
	}
	if got.HasVerifiedEmail {
		t.Fatalf("hasVerifiedEmail should be false when email_verified_at is NULL")
	}
}

func TestHandleGetMeReportsVerifiedEmail(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT handle, email_verified_at FROM members WHERE id = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestID).
		WillReturnRows(sqlmock.NewRows([]string{"handle", "email_verified_at"}).AddRow(memberTestHandle, time.Now()))

	res := doAuth(s, http.MethodGet, "/api/me", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d", res.Code)
	}
	var got publicMember
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if !got.HasVerifiedEmail {
		t.Fatalf("hasVerifiedEmail should be true")
	}
}

func TestHandleGetMeDoesNotLeakPrivateFields(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT handle, email_verified_at FROM members WHERE id = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestID).
		WillReturnRows(sqlmock.NewRows([]string{"handle", "email_verified_at"}).AddRow(memberTestHandle, nil))

	res := doAuth(s, http.MethodGet, "/api/me", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d", res.Code)
	}

	var raw map[string]any
	if err := json.NewDecoder(res.Body).Decode(&raw); err != nil {
		t.Fatalf("decode raw: %v", err)
	}
	// ADR 0016 §6: publicMember must expose id and handle only.
	for _, forbidden := range []string{"password_hash", "passwordHash", "created_at", "createdAt", "updated_at", "updatedAt", "deleted_at", "deletedAt", "email", "emailVerifiedAt", "email_verified_at"} {
		if _, ok := raw[forbidden]; ok {
			t.Fatalf("publicMember leaked field %q", forbidden)
		}
	}
}

func TestHandleDeleteMe(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectExec(regexp.QuoteMeta(`UPDATE members SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL`)).
		WithArgs(memberTestID).
		WillReturnResult(sqlmock.NewResult(0, 1))

	res := doAuth(s, http.MethodDelete, "/api/me", "", meBearer(t, s))
	if res.Code != http.StatusNoContent {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleCreateAnswerHistoryCorrect(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT correct_answer_index FROM quizzes WHERE id = $1`)).
		WithArgs(int64(42)).
		WillReturnRows(sqlmock.NewRows([]string{"correct_answer_index"}).AddRow(1))
	answeredAt := time.Date(2026, 8, 18, 12, 0, 0, 0, time.UTC)
	mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO answer_history (member_id, quiz_id, selected_index)`)).
		WithArgs(memberTestID, int64(42), 1).
		WillReturnRows(sqlmock.NewRows([]string{"id", "answered_at"}).AddRow(int64(101), answeredAt))

	res := doAuth(s, http.MethodPost, "/api/me/answers", `{"quizId":42,"selectedIndex":1}`, meBearer(t, s))
	if res.Code != http.StatusCreated {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got answerHistoryCreateResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if !got.IsCorrect {
		t.Fatalf("expected isCorrect=true, got %+v", got)
	}
}

func TestHandleCreateAnswerHistoryIncorrect(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT correct_answer_index FROM quizzes WHERE id = $1`)).
		WithArgs(int64(42)).
		WillReturnRows(sqlmock.NewRows([]string{"correct_answer_index"}).AddRow(1))
	mock.ExpectQuery(regexp.QuoteMeta(`INSERT INTO answer_history (member_id, quiz_id, selected_index)`)).
		WithArgs(memberTestID, int64(42), 0).
		WillReturnRows(sqlmock.NewRows([]string{"id", "answered_at"}).AddRow(int64(102), time.Now()))

	res := doAuth(s, http.MethodPost, "/api/me/answers", `{"quizId":42,"selectedIndex":0}`, meBearer(t, s))
	if res.Code != http.StatusCreated {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got answerHistoryCreateResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.IsCorrect {
		t.Fatalf("expected isCorrect=false, got %+v", got)
	}
}

func TestHandleCreateAnswerHistoryRejectsUnknownQuiz(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`SELECT correct_answer_index FROM quizzes WHERE id = $1`)).
		WithArgs(int64(999)).
		WillReturnRows(sqlmock.NewRows([]string{"correct_answer_index"}))

	res := doAuth(s, http.MethodPost, "/api/me/answers", `{"quizId":999,"selectedIndex":0}`, meBearer(t, s))
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleCreateAnswerHistoryRejectsNegativeIndex(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)

	res := doAuth(s, http.MethodPost, "/api/me/answers", `{"quizId":1,"selectedIndex":-1}`, meBearer(t, s))
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleListAnswerHistory(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	answeredAt := time.Date(2026, 8, 18, 12, 0, 0, 0, time.UTC)
	mock.ExpectQuery(regexp.QuoteMeta(`FROM answer_history ah`)).
		WithArgs(memberTestID, defaultAnswerHistoryPage).
		WillReturnRows(sqlmock.NewRows([]string{"id", "quiz_id", "selected_index", "is_correct", "answered_at"}).
			AddRow(int64(2), int64(42), 1, true, answeredAt).
			AddRow(int64(1), int64(42), 0, false, answeredAt.Add(-time.Hour)))

	res := doAuth(s, http.MethodGet, "/api/me/answers", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got answerHistoryListResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if len(got.Items) != 2 {
		t.Fatalf("items = %d", len(got.Items))
	}
	if !got.Items[0].IsCorrect || got.Items[1].IsCorrect {
		t.Fatalf("isCorrect order broken: %+v", got.Items)
	}
}

func TestHandleListAnswerHistoryFilteredByQuiz(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	mock.ExpectQuery(regexp.QuoteMeta(`WHERE ah.member_id = $1 AND ah.quiz_id = $2`)).
		WithArgs(memberTestID, int64(7), defaultAnswerHistoryPage).
		WillReturnRows(sqlmock.NewRows([]string{"id", "quiz_id", "selected_index", "is_correct", "answered_at"}))

	res := doAuth(s, http.MethodGet, "/api/me/answers?quizId=7", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
}

func TestHandleListAnswerHistoryRejectsBadLimit(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)

	res := doAuth(s, http.MethodGet, "/api/me/answers?limit=0", "", meBearer(t, s))
	if res.Code != http.StatusBadRequest {
		t.Fatalf("status = %d", res.Code)
	}
}
