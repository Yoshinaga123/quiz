package main

import (
	"context"
	"log"
	"os"
	"strings"
)

// Mailer is the outbound-email abstraction. Production may swap in SES /
// SendGrid; the default [stdoutMailer] just logs and is safe for dev + tests.
type Mailer interface {
	Send(ctx context.Context, to, subject, body string) error
}

type stdoutMailer struct{}

func (stdoutMailer) Send(_ context.Context, to, subject, body string) error {
	// Never log the body: password-reset / email-verification mails embed one-time tokens.
	log.Printf("[stdoutMailer] To=%s Subject=%q bodyBytes=%d", to, subject, len(body))
	return nil
}

// newMailer picks the mailer based on APP_ENV. Only stdout is wired here;
// SES/SendGrid drivers are planned in ADR 0018 §4 and will be added in a
// follow-up PR that carries the driver dependency.
func newMailer() Mailer {
	// ADR 0018 §4: never send real mail outside production.
	if strings.ToLower(os.Getenv("APP_ENV")) != "production" {
		return stdoutMailer{}
	}
	log.Printf("mailer: APP_ENV=production but no SES/SendGrid driver linked; falling back to stdout")
	return stdoutMailer{}
}
