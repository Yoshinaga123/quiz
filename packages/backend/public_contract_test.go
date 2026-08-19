package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
	"time"
)

func fixturePath(t *testing.T, name string) string {
	t.Helper()
	return filepath.Join("..", "..", "docs", "api", "fixtures", name)
}

func readFixture(t *testing.T, name string) []byte {
	t.Helper()
	data, err := os.ReadFile(fixturePath(t, name))
	if err != nil {
		t.Fatalf("read fixture %s: %v", name, err)
	}
	return data
}

func jsonTagNames(t reflect.Type) map[string]struct{} {
	names := make(map[string]struct{})
	for i := 0; i < t.NumField(); i++ {
		tag := t.Field(i).Tag.Get("json")
		name, _, _ := strings.Cut(tag, ",")
		if name == "" || name == "-" {
			continue
		}
		names[name] = struct{}{}
	}
	return names
}

func TestPublicQuizFixtureUnmarshals(t *testing.T) {
	var item publicQuiz
	if err := json.Unmarshal(readFixture(t, "quiz.json"), &item); err != nil {
		t.Fatalf("unmarshal quiz.json: %v", err)
	}
	if item.ID != 1 || item.Section != "React" || item.CorrectAnswerIndex != 0 {
		t.Fatalf("unexpected publicQuiz: %+v", item)
	}
	if item.Code == nil || *item.Code == "" {
		t.Fatal("expected code in quiz.json")
	}
	if item.CorrectAnswerIndex < 0 || item.CorrectAnswerIndex >= len(item.Options) {
		t.Fatalf("correctAnswerIndex %d out of range for %d options", item.CorrectAnswerIndex, len(item.Options))
	}
}

func TestPublicQuizListFixtureUnmarshals(t *testing.T) {
	var list publicQuizListResponse
	if err := json.Unmarshal(readFixture(t, "quiz-list.json"), &list); err != nil {
		t.Fatalf("unmarshal quiz-list.json: %v", err)
	}
	if list.TotalCount != 1 || len(list.Quizzes) != 1 {
		t.Fatalf("unexpected list: %+v", list)
	}
	if list.GeneratedAt.IsZero() {
		t.Fatal("generatedAt should parse")
	}
	if !list.GeneratedAt.Equal(time.Date(2026, 1, 15, 10, 30, 0, 0, time.UTC)) {
		t.Fatalf("generatedAt=%s", list.GeneratedAt.UTC().Format(time.RFC3339Nano))
	}
}

func TestPublicErrorAndSectionsFixtures(t *testing.T) {
	var errBody publicErrorResponse
	if err := json.Unmarshal(readFixture(t, "error.json"), &errBody); err != nil {
		t.Fatalf("unmarshal error.json: %v", err)
	}
	if errBody.Code != "not_found" || errBody.Message == "" {
		t.Fatalf("unexpected error: %+v", errBody)
	}

	var sections publicSectionListResponse
	if err := json.Unmarshal(readFixture(t, "sections.json"), &sections); err != nil {
		t.Fatalf("unmarshal sections.json: %v", err)
	}
	if len(sections.Sections) != 1 || sections.Sections[0].Section != "React" {
		t.Fatalf("unexpected sections: %+v", sections)
	}

	var feed pushFeedResponse
	if err := json.Unmarshal(readFixture(t, "push-feed.json"), &feed); err != nil {
		t.Fatalf("unmarshal push-feed.json: %v", err)
	}
	if feed.Channel != "mock" || feed.QuizID != 1 {
		t.Fatalf("unexpected feed: %+v", feed)
	}

	var accepted attemptAccepted
	if err := json.Unmarshal(readFixture(t, "attempt-accepted.json"), &accepted); err != nil {
		t.Fatalf("unmarshal attempt-accepted.json: %v", err)
	}
	if accepted.ClientSessionID == "" || accepted.Status != "accepted" {
		t.Fatalf("unexpected accepted: %+v", accepted)
	}

	var created attemptCreateRequest
	if err := json.Unmarshal(readFixture(t, "attempt-create.json"), &created); err != nil {
		t.Fatalf("unmarshal attempt-create.json: %v", err)
	}
	if created.ClientSessionID == "" || len(created.Answers) == 0 {
		t.Fatalf("unexpected create: %+v", created)
	}
}

func TestPublicQuizJSONTagsMatchFixtureKeys(t *testing.T) {
	var raw map[string]any
	if err := json.Unmarshal(readFixture(t, "quiz.json"), &raw); err != nil {
		t.Fatalf("unmarshal quiz.json map: %v", err)
	}
	tags := jsonTagNames(reflect.TypeOf(publicQuiz{}))
	for key := range raw {
		if _, ok := tags[key]; !ok {
			t.Fatalf("fixture key %q is not a publicQuiz json tag", key)
		}
	}
	required := []string{"id", "section", "title", "question", "options", "correctAnswerIndex", "explanation", "source"}
	for _, key := range required {
		if _, ok := raw[key]; !ok {
			t.Fatalf("quiz.json missing required key %q", key)
		}
		if _, ok := tags[key]; !ok {
			t.Fatalf("publicQuiz missing json tag %q", key)
		}
	}
}

func TestInvalidAnswerIndexFixtureIsOutOfRange(t *testing.T) {
	var item publicQuiz
	if err := json.Unmarshal(readFixture(t, "quiz-invalid-answer-index.json"), &item); err != nil {
		t.Fatalf("unmarshal invalid fixture: %v", err)
	}
	if item.CorrectAnswerIndex >= 0 && item.CorrectAnswerIndex < len(item.Options) {
		t.Fatal("invalid fixture should be out of range for refine parity")
	}
}
