package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestClientIPUsesRemoteAddrWhenNoXFF(t *testing.T) {
	t.Setenv("TRUSTED_PROXY_HOPS", "1")
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.RemoteAddr = "203.0.113.7:12345"
	if got := clientIP(req); got != "203.0.113.7" {
		t.Fatalf("clientIP = %q", got)
	}
}

func TestClientIPTakesRightmostForwardedHop(t *testing.T) {
	t.Setenv("TRUSTED_PROXY_HOPS", "1")
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("X-Forwarded-For", "1.1.1.1, 2.2.2.2, 3.3.3.3")
	// With 1 trusted hop the closest-to-us hop (rightmost) is 3.3.3.3.
	if got := clientIP(req); got != "3.3.3.3" {
		t.Fatalf("clientIP = %q", got)
	}
}

func TestClientIPHonoursTrustedProxyHops(t *testing.T) {
	t.Setenv("TRUSTED_PROXY_HOPS", "2")
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("X-Forwarded-For", "1.1.1.1, 2.2.2.2, 3.3.3.3")
	// With 2 trusted hops we look one further left: 2.2.2.2.
	if got := clientIP(req); got != "2.2.2.2" {
		t.Fatalf("clientIP = %q", got)
	}
}

func TestClientIPFallsBackWhenHopsExceedList(t *testing.T) {
	t.Setenv("TRUSTED_PROXY_HOPS", "5")
	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("X-Forwarded-For", "1.1.1.1, 2.2.2.2")
	if got := clientIP(req); got != "1.1.1.1" {
		t.Fatalf("clientIP = %q", got)
	}
}

func TestTrustedProxyHopsDefaults(t *testing.T) {
	t.Setenv("TRUSTED_PROXY_HOPS", "")
	if got := trustedProxyHops(); got != 1 {
		t.Fatalf("default trustedProxyHops = %d", got)
	}
	t.Setenv("TRUSTED_PROXY_HOPS", "-3")
	if got := trustedProxyHops(); got != 1 {
		t.Fatalf("negative TRUSTED_PROXY_HOPS should fall back to 1, got %d", got)
	}
	t.Setenv("TRUSTED_PROXY_HOPS", "abc")
	if got := trustedProxyHops(); got != 1 {
		t.Fatalf("non-numeric TRUSTED_PROXY_HOPS should fall back to 1, got %d", got)
	}
}
