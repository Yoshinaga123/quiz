package main

import (
	"crypto/rand"
	"database/sql"
	"fmt"
	"math/big"
	"net/http"
	"sync"
	"time"
)

const verificationPrompt = "quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。"
const defaultSeedPath = "../admin-web/src/data/quizzes.json"
const defaultMigrationsDir = "migrations"
const defaultSeedMigrationName = "seed_quizzes"
const defaultSeedGeneratorScript = "../scripts/generate_migration.py"

type server struct {
	db                     *sql.DB
	adminUser              string
	adminPassword          string
	jwtSecret              []byte
	verificationMu         sync.Mutex
	pendingVerifications   map[string]verificationChallenge
	returnVerificationCode bool
	seedMu                 sync.Mutex
	pushMu                 sync.Mutex
}

type rowScanner interface {
	Scan(dest ...any) error
}

type errorResponse struct {
	Error  string `json:"error"`
	Code   string `json:"code,omitempty"`
	Detail string `json:"detail,omitempty"`
}

type healthResponse struct {
	Status string `json:"status"`
}

type countResponse struct {
	Count int `json:"count"`
}

type loginRequest struct {
	Username         string `json:"username"`
	Password         string `json:"password"`
	ChallengeID      string `json:"challengeId"`
	VerificationCode string `json:"verificationCode"`
}

type loginResponse struct {
	Token string `json:"token"`
}

type verificationResponse struct {
	Message     string `json:"message"`
	ChallengeID string `json:"challengeId"`
	Code        string `json:"code,omitempty"`
}

type verificationChallenge struct {
	Username  string
	Code      string
	ExpiresAt time.Time
}

func generateChallengeID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return fmt.Sprintf("%x", b), nil
}

func generateVerificationCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

type quiz struct {
	ID                 int64     `json:"id"`
	Section            string    `json:"section"`
	Title              string    `json:"title"`
	Question           string    `json:"question"`
	Code               *string   `json:"code,omitempty"`
	Options            []string  `json:"options"`
	CorrectAnswerIndex int       `json:"correctAnswerIndex"`
	Explanation        string    `json:"explanation"`
	Source             string    `json:"source"`
	Status             string    `json:"status"`
	PushEnabled        bool      `json:"pushEnabled"`
	CreatedAt          time.Time `json:"createdAt"`
	UpdatedAt          time.Time `json:"updatedAt"`
}

type quizListResponse struct {
	Items      []quiz `json:"items"`
	Total      int    `json:"total"`
	Page       int    `json:"page"`
	PerPage    int    `json:"perPage"`
	TotalPages int    `json:"totalPages"`
}

type quizPayload struct {
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               string   `json:"code"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
	Status             string   `json:"status"`
	PushEnabled        bool     `json:"pushEnabled"`
}

type productionSeedDocument struct {
	Quizzes []productionSeedQuiz `json:"quizzes"`
}

type productionSeedQuiz struct {
	ID                 int64    `json:"id"`
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               *string  `json:"code,omitempty"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
	Published          *bool    `json:"published"`
}

type productionSeedSyncResponse struct {
	SeededCount      int    `json:"seededCount"`
	DeletedCount     int    `json:"deletedCount"`
	Source           string `json:"source"`
	MigrationVersion int    `json:"migrationVersion"`
	UpPath           string `json:"upPath"`
	DownPath         string `json:"downPath"`
}

// publicQuiz は公開 API (/v1/quizzes) で返す、個人情報を含まないクイズの形状。
// docs/api/public-quiz-api.yaml の #/components/schemas/Quiz と構造を一致させ、
// 管理用フィールド (status, pushEnabled, createdAt, updatedAt) は意図的に除外する。
type publicQuiz struct {
	ID                 int64    `json:"id"`
	Section            string   `json:"section"`
	Title              string   `json:"title"`
	Question           string   `json:"question"`
	Code               *string  `json:"code,omitempty"`
	Options            []string `json:"options"`
	CorrectAnswerIndex int      `json:"correctAnswerIndex"`
	Explanation        string   `json:"explanation"`
	Source             string   `json:"source"`
}

type publicQuizListResponse struct {
	Quizzes     []publicQuiz `json:"quizzes"`
	TotalCount  int          `json:"totalCount"`
	GeneratedAt time.Time    `json:"generatedAt"`
}

type sectionSummary struct {
	Section string `json:"section"`
	Count   int    `json:"count"`
}

type publicSectionListResponse struct {
	Sections []sectionSummary `json:"sections"`
}

type mockPushCandidate struct {
	QuizID   int64
	Title    string
	Question string
}

type pushDispatchResponse struct {
	DeliveryID  int64     `json:"deliveryId"`
	QuizID      int64     `json:"quizId"`
	Title       string    `json:"title"`
	Channel     string    `json:"channel"`
	TargetCount int       `json:"targetCount"`
	Status      string    `json:"status"`
	SentAt      time.Time `json:"sentAt"`
}

type pushDelivery struct {
	DeliveryID  int64     `json:"deliveryId"`
	QuizID      int64     `json:"quizId"`
	Title       string    `json:"title"`
	Channel     string    `json:"channel"`
	TargetCount int       `json:"targetCount"`
	Status      string    `json:"status"`
	ErrorDetail *string   `json:"errorDetail,omitempty"`
	SentAt      time.Time `json:"sentAt"`
}

type pushDeliveryListResponse struct {
	Items      []pushDelivery `json:"items"`
	Total      int            `json:"total"`
	Page       int            `json:"page"`
	PerPage    int            `json:"perPage"`
	TotalPages int            `json:"totalPages"`
}

type pushFeedResponse struct {
	DeliveryID int64     `json:"deliveryId"`
	QuizID     int64     `json:"quizId"`
	Title      string    `json:"title"`
	Body       string    `json:"body"`
	SentAt     time.Time `json:"sentAt"`
	Channel    string    `json:"channel"`
}

// publicErrorResponse は ADR 0006 で合意した公開 API のエラー形式。
// 管理 API の errorResponse とは別フォーマットとし、
// クライアント（web, mobile）は `code` でハンドリングできる。
type publicErrorResponse struct {
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details,omitempty"`
}

type statusError struct {
	Status  int
	Message string
	Err     error
}

func (e *statusError) Error() string {
	if e.Message != "" {
		return e.Message
	}
	if e.Err != nil {
		return e.Err.Error()
	}
	return http.StatusText(e.Status)
}

func (e *statusError) Unwrap() error {
	return e.Err
}
