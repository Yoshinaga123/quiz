package main

import (
	"bytes"
	"context"
	"database/sql"
	"embed"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	_ "github.com/lib/pq"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func getMigrationsDir() string {
	return getEnv("QUIZ_MIGRATIONS_DIR", defaultMigrationsDir)
}

func getSeedGeneratorScriptPath() (string, error) {
	candidates := []string{
		os.Getenv("QUIZ_SEED_GENERATOR_SCRIPT"),
		defaultSeedGeneratorScript,
		filepath.Join("scripts", "generate_migration.py"),
	}

	for _, candidate := range candidates {
		if candidate == "" {
			continue
		}

		info, err := os.Stat(candidate)
		if err == nil && !info.IsDir() {
			return candidate, nil
		}
	}

	return "", fmt.Errorf("seed generator script not found")
}

func getMigrateBinaryPath() (string, error) {
	if value := os.Getenv("QUIZ_MIGRATE_BIN"); value != "" {
		return value, nil
	}

	if path, err := exec.LookPath("migrate"); err == nil {
		return path, nil
	}

	candidates := []string{
		"/go/bin/migrate",
		filepath.Join(os.Getenv("HOME"), ".local", "bin", "migrate"),
	}
	for _, candidate := range candidates {
		if candidate == "" {
			continue
		}
		info, err := os.Stat(candidate)
		if err == nil && !info.IsDir() {
			return candidate, nil
		}
	}

	return "", fmt.Errorf("migrate binary not found")
}

func runCommand(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	output, err := cmd.CombinedOutput()
	outputText := strings.TrimSpace(string(output))
	if err != nil {
		if outputText == "" {
			return "", err
		}
		return "", fmt.Errorf("%w: %s", err, outputText)
	}
	return outputText, nil
}

func runCommandStdout(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	output, err := cmd.Output()
	outputText := strings.TrimSpace(string(output))
	stderrText := strings.TrimSpace(stderr.String())
	if err != nil {
		if stderrText == "" {
			return "", err
		}
		return "", fmt.Errorf("%w: %s", err, stderrText)
	}

	return outputText, nil
}

func newMigrator(db *sql.DB) (*migrate.Migrate, error) {
	dbDriver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		return nil, err
	}

	migrationsDir := getMigrationsDir()
	if info, err := os.Stat(migrationsDir); err == nil && info.IsDir() {
		absDir, err := filepath.Abs(migrationsDir)
		if err != nil {
			return nil, err
		}

		return migrate.NewWithDatabaseInstance("file://"+absDir, "postgres", dbDriver)
	}

	srcDriver, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		return nil, err
	}

	return migrate.NewWithInstance("iofs", srcDriver, "postgres", dbDriver)
}

func databaseDSN() string {
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "password")
	name := getEnv("DB_NAME", "counter")

	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host,
		port,
		user,
		password,
		name,
	)
}

func openAppDB() (*sql.DB, error) {
	db, err := sql.Open("postgres", databaseDSN())
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		_ = db.Close()
		return nil, err
	}

	return db, nil
}

func initDB() (*sql.DB, error) {
	if err := runMigrations(); err != nil {
		return nil, fmt.Errorf("migration: %w", err)
	}

	return openAppDB()
}

func runMigrations() error {
	db, err := openAppDB()
	if err != nil {
		return err
	}

	m, err := newMigrator(db)
	if err != nil {
		_ = db.Close()
		return err
	}
	defer func() {
		sourceErr, databaseErr := m.Close()
		if sourceErr != nil {
			log.Printf("close migration source: %v", sourceErr)
		}
		if databaseErr != nil {
			log.Printf("close migration database: %v", databaseErr)
		}
	}()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}

	return nil
}
