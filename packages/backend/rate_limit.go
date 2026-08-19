package main

import (
	"context"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

// Rate limit thresholds per ADR 0017.
const (
	memberSessionWindow    = 5 * time.Minute
	memberSessionIPLimit   = 20
	memberSessionUserLimit = 5

	memberRegisterWindow  = time.Hour
	memberRegisterIPLimit = 10

	adminLoginWindow    = 5 * time.Minute
	adminLoginIPLimit   = 20
	adminLoginUserLimit = 5
)

type rateLimitKind int

const (
	rateLimitByIP rateLimitKind = iota
	rateLimitByHandle
)

// clientIP returns the origin IP for the request, honouring TRUSTED_PROXY_HOPS
// hops of X-Forwarded-For from the right (per ADR 0017 §2).
func clientIP(r *http.Request) string {
	hops := trustedProxyHops()
	xff := r.Header.Get("X-Forwarded-For")
	if hops > 0 && xff != "" {
		parts := strings.Split(xff, ",")
		idx := len(parts) - hops
		if idx < 0 {
			idx = 0
		}
		candidate := strings.TrimSpace(parts[idx])
		if candidate != "" {
			return candidate
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func trustedProxyHops() int {
	raw := strings.TrimSpace(os.Getenv("TRUSTED_PROXY_HOPS"))
	if raw == "" {
		return 1
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n < 0 {
		return 1
	}
	return n
}

// countFailedLogins returns how many failed login attempts happened in the
// given window for the given key. ADR 0017 §Decision.1: only failures count.
func (s *server) countFailedLogins(ctx context.Context, table, column, key string, window time.Duration) (int, error) {
	// Table + column are validated caller-side (constants), never user input.
	query := "SELECT COUNT(*) FROM " + table +
		" WHERE " + column + " = $1 AND success = FALSE AND created_at > $2"
	var count int
	if err := s.db.QueryRowContext(ctx, query, key, time.Now().Add(-window)).Scan(&count); err != nil {
		return 0, err
	}
	return count, nil
}

// rateLimitExceeded returns true when either the IP or the identity has hit
// its limit. Callers should always continue to run bcrypt/verification before
// consulting this, so 429 and 401 have similar timing (ADR 0017 §1).
func (s *server) rateLimitExceeded(
	ctx context.Context,
	table, identityColumn, identityKey, ip string,
	window time.Duration,
	ipLimit, identityLimit int,
) (bool, error) {
	if ipLimit > 0 && ip != "" {
		count, err := s.countFailedLogins(ctx, table, "ip_address", ip, window)
		if err != nil {
			return false, err
		}
		if count >= ipLimit {
			return true, nil
		}
	}
	if identityLimit > 0 && identityKey != "" {
		count, err := s.countFailedLogins(ctx, table, identityColumn, identityKey, window)
		if err != nil {
			return false, err
		}
		if count >= identityLimit {
			return true, nil
		}
	}
	return false, nil
}

// writeRateLimited writes the ADR 0006 public error envelope with a Retry-After
// hint of the full window (upper bound of when the caller may retry).
func writeRateLimited(w http.ResponseWriter, window time.Duration) {
	w.Header().Set("Retry-After", strconv.Itoa(int(window.Seconds())))
	writePublicError(w, http.StatusTooManyRequests, "rate_limited", "too many attempts; try again later")
}
