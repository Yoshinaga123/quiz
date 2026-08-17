package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/golang-migrate/migrate/v4"
	"github.com/lib/pq"
)

func normalizeQuizPayload(payload *quizPayload) error {
	payload.Section = strings.TrimSpace(payload.Section)
	payload.Title = strings.TrimSpace(payload.Title)
	payload.Question = strings.TrimSpace(payload.Question)
	payload.Code = strings.TrimSpace(payload.Code)
	payload.Explanation = strings.TrimSpace(payload.Explanation)
	payload.Source = strings.TrimSpace(payload.Source)
	payload.Status = strings.TrimSpace(payload.Status)

	if payload.Section == "" {
		return errors.New("section is required")
	}
	if payload.Title == "" {
		return errors.New("title is required")
	}
	if payload.Question == "" {
		return errors.New("question is required")
	}
	if payload.Explanation == "" {
		return errors.New("explanation is required")
	}
	if payload.Source == "" {
		return errors.New("source is required")
	}
	if payload.Status != "published" && payload.Status != "unpublished" {
		return errors.New("status must be published or unpublished")
	}

	if len(payload.Options) < 2 {
		return errors.New("at least two options are required")
	}

	for index := range payload.Options {
		payload.Options[index] = strings.TrimSpace(payload.Options[index])
		if payload.Options[index] == "" {
			return fmt.Errorf("option %d is required", index+1)
		}
	}

	if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
		return errors.New("correctAnswerIndex is out of range")
	}

	return nil
}

func normalizeProductionSeedQuiz(payload *productionSeedQuiz) error {
	payload.Section = strings.TrimSpace(payload.Section)
	payload.Title = strings.TrimSpace(payload.Title)
	payload.Question = strings.TrimSpace(payload.Question)
	payload.Explanation = strings.TrimSpace(payload.Explanation)
	payload.Source = strings.TrimSpace(payload.Source)

	if payload.Code != nil {
		trimmed := strings.TrimSpace(*payload.Code)
		if trimmed == "" {
			payload.Code = nil
		} else {
			payload.Code = &trimmed
		}
	}

	if payload.ID <= 0 {
		return errors.New("id must be positive")
	}
	if payload.Section == "" {
		return fmt.Errorf("section is required for quiz id %d", payload.ID)
	}
	if payload.Title == "" {
		return fmt.Errorf("title is required for quiz id %d", payload.ID)
	}
	if payload.Question == "" {
		return fmt.Errorf("question is required for quiz id %d", payload.ID)
	}
	if payload.Explanation == "" {
		return fmt.Errorf("explanation is required for quiz id %d", payload.ID)
	}
	if payload.Source == "" {
		return fmt.Errorf("source is required for quiz id %d", payload.ID)
	}
	if len(payload.Options) < 2 {
		return fmt.Errorf("at least two options are required for quiz id %d", payload.ID)
	}

	for index := range payload.Options {
		payload.Options[index] = strings.TrimSpace(payload.Options[index])
		if payload.Options[index] == "" {
			return fmt.Errorf("option %d is required for quiz id %d", index+1, payload.ID)
		}
	}

	if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
		return fmt.Errorf("correctAnswerIndex is out of range for quiz id %d", payload.ID)
	}

	return nil
}

func validateProductionSeedDocument(document *productionSeedDocument) error {
	seenIDs := make(map[int64]struct{}, len(document.Quizzes))
	for _, quiz := range document.Quizzes {
		if _, exists := seenIDs[quiz.ID]; exists {
			return fmt.Errorf("duplicate quiz id in production seed: %d", quiz.ID)
		}
		seenIDs[quiz.ID] = struct{}{}
	}

	return nil
}

func getProductionSeedPath() string {
	if value := os.Getenv("QUIZ_PRODUCTION_SEED_PATH"); value != "" {
		return value
	}
	return defaultProductionSeedPath
}

func loadProductionSeedDocument(seedPath string) (productionSeedDocument, error) {
	content, err := os.ReadFile(seedPath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return productionSeedDocument{}, &statusError{
				Status:  http.StatusNotFound,
				Message: fmt.Sprintf("production seed file not found: %s", seedPath),
				Err:     err,
			}
		}
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: fmt.Sprintf("failed to read production seed file: %s", seedPath),
			Err:     err,
		}
	}

	var document productionSeedDocument
	if err := json.Unmarshal(content, &document); err != nil {
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusUnprocessableEntity,
			Message: fmt.Sprintf("production seed JSON is invalid: %s", seedPath),
			Err:     err,
		}
	}

	for index := range document.Quizzes {
		if err := normalizeProductionSeedQuiz(&document.Quizzes[index]); err != nil {
			return productionSeedDocument{}, &statusError{
				Status:  http.StatusUnprocessableEntity,
				Message: err.Error(),
				Err:     err,
			}
		}
	}

	if err := validateProductionSeedDocument(&document); err != nil {
		return productionSeedDocument{}, &statusError{
			Status:  http.StatusUnprocessableEntity,
			Message: err.Error(),
			Err:     err,
		}
	}

	return document, nil
}

func countDeletedQuizzes(ctx context.Context, db *sql.DB, ids []int64) (int, error) {
	var deletedCount int

	if len(ids) == 0 {
		if err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM quizzes`).Scan(&deletedCount); err != nil {
			return 0, err
		}
		return deletedCount, nil
	}

	if err := db.QueryRowContext(
		ctx,
		`SELECT COUNT(*) FROM quizzes WHERE NOT (id = ANY($1))`,
		pq.Array(ids),
	).Scan(&deletedCount); err != nil {
		return 0, err
	}

	return deletedCount, nil
}

func parseCreatedMigrationPaths(output string) (string, string, error) {
	lines := strings.Split(output, "\n")
	var upPath string
	var downPath string

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}

		if strings.HasSuffix(trimmed, ".up.sql") {
			upPath = filepath.ToSlash(trimmed)
		}
		if strings.HasSuffix(trimmed, ".down.sql") {
			downPath = filepath.ToSlash(trimmed)
		}
	}

	if upPath == "" || downPath == "" {
		return "", "", fmt.Errorf("unexpected migrate create output: %s", output)
	}

	return upPath, downPath, nil
}

func migrationVersionFromPath(path string) (int, error) {
	base := filepath.Base(path)
	underscore := strings.IndexByte(base, '_')
	if underscore <= 0 {
		return 0, fmt.Errorf("invalid migration filename: %s", base)
	}
	return strconv.Atoi(base[:underscore])
}

func generateProductionSeedMigrationSQL(ctx context.Context, mode, seedPath string) (string, error) {
	scriptPath, err := getSeedGeneratorScriptPath()
	if err != nil {
		return "", fmt.Errorf("locate seed generator script: %w", err)
	}

	pythonBin := getEnv("QUIZ_PYTHON_BIN", "python3")
	log.Printf("[migration] generating %s SQL: %s %s --mode %s --input %s", mode, pythonBin, scriptPath, mode, seedPath)

	output, err := runCommandStdout(
		ctx,
		pythonBin,
		scriptPath,
		"--mode",
		mode,
		"--input",
		seedPath,
		"--source-label",
		filepath.Base(seedPath),
	)
	if err != nil {
		return "", fmt.Errorf("run %s %s (mode=%s): %w", pythonBin, scriptPath, mode, err)
	}

	if output == "" {
		return "", fmt.Errorf("generated %s SQL is empty (script=%s, input=%s)", mode, scriptPath, seedPath)
	}

	log.Printf("[migration] generated %s SQL: %d bytes", mode, len(output))
	return output + "\n", nil
}

func displayMigrationPath(actualPath string) string {
	migrationsDir := getMigrationsDir()
	filename := filepath.Base(actualPath)
	if filepath.IsAbs(migrationsDir) {
		return filepath.ToSlash(filepath.Join(migrationsDir, filename))
	}
	return filepath.ToSlash(filepath.Join("backend", migrationsDir, filename))
}

func createProductionSeedMigrationFiles(ctx context.Context, seedPath string) (int, string, string, error) {
	migrationsDir := getMigrationsDir()
	log.Printf("[migration] migrationsDir=%s, seedPath=%s", migrationsDir, seedPath)

	if err := os.MkdirAll(migrationsDir, 0o755); err != nil {
		return 0, "", "", fmt.Errorf("mkdir %s: %w", migrationsDir, err)
	}

	migrateBin, err := getMigrateBinaryPath()
	if err != nil {
		return 0, "", "", fmt.Errorf("locate migrate binary: %w", err)
	}
	log.Printf("[migration] migrate binary: %s", migrateBin)

	createOutput, err := runCommand(
		ctx,
		migrateBin,
		"create",
		"-ext",
		"sql",
		"-dir",
		migrationsDir,
		"-seq",
		"-digits",
		"3",
		defaultSeedMigrationName,
	)
	if err != nil {
		return 0, "", "", fmt.Errorf("migrate create: %w", err)
	}
	log.Printf("[migration] migrate create output: %s", createOutput)

	upRelativePath, downRelativePath, err := parseCreatedMigrationPaths(createOutput)
	if err != nil {
		return 0, "", "", fmt.Errorf("parse migration paths from output %q: %w", createOutput, err)
	}
	log.Printf("[migration] up=%s, down=%s", upRelativePath, downRelativePath)

	version, err := migrationVersionFromPath(upRelativePath)
	if err != nil {
		return 0, "", "", fmt.Errorf("extract version from %s: %w", upRelativePath, err)
	}

	upSQL, err := generateProductionSeedMigrationSQL(ctx, "up", seedPath)
	if err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("generate up SQL: %w", err)
	}

	downSQL, err := generateProductionSeedMigrationSQL(ctx, "down", seedPath)
	if err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("generate down SQL: %w", err)
	}

	if err := os.WriteFile(upRelativePath, []byte(upSQL), 0o644); err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("write %s: %w", upRelativePath, err)
	}
	if err := os.WriteFile(downRelativePath, []byte(downSQL), 0o644); err != nil {
		_ = os.Remove(upRelativePath)
		_ = os.Remove(downRelativePath)
		return 0, "", "", fmt.Errorf("write %s: %w", downRelativePath, err)
	}

	log.Printf("[migration] created version %d successfully", version)
	return version, displayMigrationPath(upRelativePath), displayMigrationPath(downRelativePath), nil
}

func applyGeneratedMigrations() error {
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

	if err := m.Up(); err != nil {
		var dirtyErr migrate.ErrDirty
		if errors.As(err, &dirtyErr) {
			return &statusError{
				Status:  http.StatusConflict,
				Message: fmt.Sprintf("database is dirty at migration version %d", dirtyErr.Version),
				Err:     err,
			}
		}
		if errors.Is(err, migrate.ErrNoChange) {
			return nil
		}
		return &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to apply generated migration",
			Err:     err,
		}
	}

	return nil
}

func (s *server) syncProductionSeedQuizzes(ctx context.Context) (productionSeedSyncResponse, error) {
	seedPath := getProductionSeedPath()
	document, err := loadProductionSeedDocument(seedPath)
	if err != nil {
		return productionSeedSyncResponse{}, err
	}

	ids := make([]int64, 0, len(document.Quizzes))
	for _, quiz := range document.Quizzes {
		ids = append(ids, quiz.ID)
	}

	deletedCount, err := countDeletedQuizzes(ctx, s.db, ids)
	if err != nil {
		return productionSeedSyncResponse{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to calculate replace impact",
			Err:     err,
		}
	}

	version, upPath, downPath, err := createProductionSeedMigrationFiles(ctx, seedPath)
	if err != nil {
		return productionSeedSyncResponse{}, &statusError{
			Status:  http.StatusInternalServerError,
			Message: "failed to generate production seed migration files",
			Err:     err,
		}
	}

	if err := applyGeneratedMigrations(); err != nil {
		return productionSeedSyncResponse{}, err
	}

	return productionSeedSyncResponse{
		SeededCount:      len(document.Quizzes),
		DeletedCount:     deletedCount,
		Source:           seedPath,
		MigrationVersion: version,
		UpPath:           upPath,
		DownPath:         downPath,
	}, nil
}
