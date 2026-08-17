package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func (s *server) issueJWT() (string, error) {
	claims := jwt.RegisteredClaims{
		Subject:   s.adminUser,
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

func (s *server) requireAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		header := r.Header.Get("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			writeError(w, http.StatusUnauthorized, "missing bearer token")
			return
		}

		tokenString := strings.TrimPrefix(header, "Bearer ")
		claims := &jwt.RegisteredClaims{}
		token, err := jwt.ParseWithClaims(
			tokenString,
			claims,
			func(token *jwt.Token) (any, error) {
				if token.Method != jwt.SigningMethodHS256 {
					return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
				}
				return s.jwtSecret, nil
			},
		)
		if err != nil || !token.Valid {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		next.ServeHTTP(w, r)
	})
}

// handleLogin godoc
//
//	@Summary		管理者ログイン
//	@Description	ユーザー名・パスワードで認証し JWT を発行する
//	@Tags			auth
//	@Accept			json
//	@Produce		json
//	@Param			body	body		loginRequest	true	"認証情報"
//	@Success		200		{object}	loginResponse
//	@Failure		400		{object}	errorResponse
//	@Failure		401		{object}	errorResponse
//	@Failure		500		{object}	errorResponse
//	@Router			/api/admin/login [post]
func (s *server) recordLoginLog(username string, success bool, r *http.Request) {
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip = r.RemoteAddr
	}
	ua := r.UserAgent()

	_, err := s.db.Exec(
		`INSERT INTO login_logs (username, success, ip_address, user_agent) VALUES ($1, $2, $3, $4)`,
		username, success, ip, ua,
	)
	if err != nil {
		log.Printf("failed to record login log: %v", err)
	}
}

func (s *server) createVerificationChallenge(username string) (string, string, error) {
	challengeID, err := generateChallengeID()
	if err != nil {
		return "", "", err
	}
	code, err := generateVerificationCode()
	if err != nil {
		return "", "", err
	}

	s.verificationMu.Lock()
	s.pendingVerifications[challengeID] = verificationChallenge{
		Username:  username,
		Code:      code,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}
	s.verificationMu.Unlock()

	log.Printf("verification code for %s: %s (challenge %s)", username, code, challengeID)

	return challengeID, code, nil
}

func (s *server) consumeVerification(username, challengeID, code string) bool {
	s.verificationMu.Lock()
	defer s.verificationMu.Unlock()

	challenge, ok := s.pendingVerifications[challengeID]
	if !ok {
		return false
	}
	if challenge.Username != username {
		return false
	}
	if time.Now().After(challenge.ExpiresAt) {
		delete(s.pendingVerifications, challengeID)
		return false
	}
	if challenge.Code != code {
		return false
	}

	delete(s.pendingVerifications, challengeID)
	return true
}

func (s *server) handleRequestLoginVerification(w http.ResponseWriter, r *http.Request) {
	var payload loginRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid login payload")
		return
	}

	if payload.Username != s.adminUser || payload.Password != s.adminPassword {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	challengeID, code, err := s.createVerificationChallenge(payload.Username)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create verification challenge")
		return
	}

	writeJSON(w, http.StatusOK, verificationResponse{
		Message:     verificationPrompt,
		ChallengeID: challengeID,
		Code:        code,
	})
}

func (s *server) handleLogin(w http.ResponseWriter, r *http.Request) {
	var payload loginRequest
	if err := decodeJSON(r, &payload); err != nil {
		writeError(w, http.StatusBadRequest, "invalid login payload")
		return
	}

	if payload.Username != s.adminUser || payload.Password != s.adminPassword {
		s.recordLoginLog(payload.Username, false, r)
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	if payload.ChallengeID == "" || payload.VerificationCode == "" {
		writeError(w, http.StatusBadRequest, "verification code required")
		return
	}

	if !s.consumeVerification(payload.Username, payload.ChallengeID, payload.VerificationCode) {
		s.recordLoginLog(payload.Username, false, r)
		writeError(w, http.StatusUnauthorized, "invalid or expired verification code")
		return
	}

	token, err := s.issueJWT()
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create token")
		return
	}

	s.recordLoginLog(payload.Username, true, r)
	writeJSON(w, http.StatusOK, loginResponse{Token: token})
}
