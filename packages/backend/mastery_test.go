package main

import (
	"encoding/json"
	"net/http"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

// masteryHistoryRow is a small helper for TestHandleGetMemberMastery table cases.
type masteryHistoryRow struct {
	quizID    int64
	isCorrect bool
	answered  time.Time
}

func expectMasteryDBQueries(mock sqlmock.Sqlmock, publishedIDs []int64, history []masteryHistoryRow) {
	quizRows := sqlmock.NewRows([]string{"id"})
	for _, id := range publishedIDs {
		quizRows.AddRow(id)
	}
	mock.ExpectQuery(regexp.QuoteMeta(
		"SELECT id FROM quizzes WHERE status = 'published' ORDER BY id ASC",
	)).WillReturnRows(quizRows)

	historyRows := sqlmock.NewRows([]string{"quiz_id", "is_correct", "answered_at"})
	for _, r := range history {
		historyRows.AddRow(r.quizID, r.isCorrect, r.answered)
	}
	mock.ExpectQuery(regexp.QuoteMeta("FROM answer_history ah")).
		WithArgs(memberTestID).
		WillReturnRows(historyRows)
}

func TestHandleGetMemberMasteryEmpty(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	expectMasteryDBQueries(mock, nil, nil)

	res := doAuth(s, http.MethodGet, "/api/me/mastery", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}

	var got masteryResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if len(got.Items) != 0 {
		t.Fatalf("items = %d, want 0", len(got.Items))
	}
	if got.StreakCap != masteryStreakCap {
		t.Fatalf("streakCap = %d, want %d", got.StreakCap, masteryStreakCap)
	}
	if got.Rank.Rank != "4級" {
		t.Fatalf("rank = %q, want 4級", got.Rank.Rank)
	}
	if got.Rank.TotalPossible != 0 {
		t.Fatalf("totalPossible = %d, want 0 (no published quizzes)", got.Rank.TotalPossible)
	}
}

func TestHandleGetMemberMasteryConsecutiveCapped(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	base := time.Date(2026, 8, 18, 12, 0, 0, 0, time.UTC)
	expectMasteryDBQueries(mock,
		[]int64{1},
		[]masteryHistoryRow{
			{quizID: 1, isCorrect: true, answered: base},
			{quizID: 1, isCorrect: true, answered: base.Add(time.Minute)},
			{quizID: 1, isCorrect: true, answered: base.Add(2 * time.Minute)},
		},
	)

	res := doAuth(s, http.MethodGet, "/api/me/mastery", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got masteryResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if len(got.Items) != 1 || got.Items[0].QuizID != 1 || got.Items[0].Streak != masteryStreakCap {
		t.Fatalf("items = %+v", got.Items)
	}
	if got.Rank.Mastery != masteryStreakCap {
		t.Fatalf("mastery = %d, want %d (capped)", got.Rank.Mastery, masteryStreakCap)
	}
	if got.Rank.Rank != "名人" {
		t.Fatalf("rank = %q, want 名人 (full mastery of a 1-quiz catalog)", got.Rank.Rank)
	}
}

func TestHandleGetMemberMasteryResetsOnWrong(t *testing.T) {
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	base := time.Date(2026, 8, 18, 12, 0, 0, 0, time.UTC)
	expectMasteryDBQueries(mock,
		[]int64{1, 2, 3},
		[]masteryHistoryRow{
			{quizID: 1, isCorrect: true, answered: base},
			{quizID: 1, isCorrect: false, answered: base.Add(time.Minute)},
			{quizID: 1, isCorrect: true, answered: base.Add(2 * time.Minute)},
			{quizID: 2, isCorrect: true, answered: base},
			{quizID: 2, isCorrect: true, answered: base.Add(time.Minute)},
		},
	)

	res := doAuth(s, http.MethodGet, "/api/me/mastery", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got masteryResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	byID := make(map[int64]int)
	for _, item := range got.Items {
		byID[item.QuizID] = item.Streak
	}
	if byID[1] != 1 {
		t.Fatalf("quiz 1 streak = %d, want 1 (correct, wrong, correct)", byID[1])
	}
	if byID[2] != 2 {
		t.Fatalf("quiz 2 streak = %d, want 2", byID[2])
	}
	// quiz 3 never answered: not in items but included in totalPossible.
	if got.Rank.TotalPossible != 3*masteryStreakCap {
		t.Fatalf("totalPossible = %d, want %d", got.Rank.TotalPossible, 3*masteryStreakCap)
	}
	if got.Rank.Mastery != 3 {
		t.Fatalf("mastery = %d, want 3 (quiz1=1 + quiz2=2)", got.Rank.Mastery)
	}
}

func TestHandleGetMemberMasteryExcludesUnpublished(t *testing.T) {
	// answer_history に 999 番の履歴があっても、公開クイズ ID に含まれなければ
	// 段位計算から外れる。
	s, mock, cleanup := newMockMemberServer(t)
	defer cleanup()

	expectActiveMemberLookup(mock)
	base := time.Date(2026, 8, 18, 12, 0, 0, 0, time.UTC)
	expectMasteryDBQueries(mock,
		[]int64{1, 2},
		[]masteryHistoryRow{
			{quizID: 1, isCorrect: true, answered: base},
			{quizID: 999, isCorrect: true, answered: base},
			{quizID: 999, isCorrect: true, answered: base.Add(time.Minute)},
		},
	)

	res := doAuth(s, http.MethodGet, "/api/me/mastery", "", meBearer(t, s))
	if res.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %s", res.Code, res.Body.String())
	}
	var got masteryResponse
	if err := json.NewDecoder(res.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.Rank.Mastery != 1 {
		t.Fatalf("mastery = %d, want 1 (999 must be excluded)", got.Rank.Mastery)
	}
	if got.Rank.TotalPossible != 4 {
		t.Fatalf("totalPossible = %d, want 4", got.Rank.TotalPossible)
	}
}

func TestHandleGetMemberMasteryRequiresAuth(t *testing.T) {
	s, _, cleanup := newMockMemberServer(t)
	defer cleanup()

	res := doAuth(s, http.MethodGet, "/api/me/mastery", "", "")
	if res.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", res.Code)
	}
}

// ---- pure rank calc tests ----

func TestComputeMasteryRankEmpty(t *testing.T) {
	r := computeMasteryRank(map[int64]int{}, []int64{1, 2, 3, 4, 5})
	if r.Rank != "4級" {
		t.Fatalf("rank = %q, want 4級", r.Rank)
	}
	if r.Mastery != 0 || r.TotalPossible != 10 {
		t.Fatalf("mastery=%d totalPossible=%d", r.Mastery, r.TotalPossible)
	}
	if r.NextRank == nil || *r.NextRank != "3級" {
		t.Fatalf("nextRank = %v", r.NextRank)
	}
}

func TestComputeMasteryRankNoQuizzes(t *testing.T) {
	r := computeMasteryRank(map[int64]int{}, nil)
	if r.Rank != "4級" {
		t.Fatalf("rank = %q, want 4級", r.Rank)
	}
	if r.TotalPossible != 0 {
		t.Fatalf("totalPossible = %d, want 0", r.TotalPossible)
	}
}

func TestComputeMasteryRankPerfect(t *testing.T) {
	ids := []int64{1, 2, 3, 4, 5}
	streaks := map[int64]int{1: 2, 2: 2, 3: 2, 4: 2, 5: 2}
	r := computeMasteryRank(streaks, ids)
	if r.Rank != "名人" {
		t.Fatalf("rank = %q, want 名人", r.Rank)
	}
	if r.NextRank != nil {
		t.Fatalf("nextRank = %v, want nil", r.NextRank)
	}
	if r.ToNextRank != 0 {
		t.Fatalf("toNextRank = %d, want 0", r.ToNextRank)
	}
	if r.Progress != 1 {
		t.Fatalf("progress = %v, want 1", r.Progress)
	}
}

func TestComputeMasteryRankAlmostPerfect(t *testing.T) {
	ids := []int64{1, 2, 3, 4, 5}
	streaks := map[int64]int{1: 1, 2: 2, 3: 2, 4: 2, 5: 2}
	r := computeMasteryRank(streaks, ids)
	if r.Rank == "名人" {
		t.Fatalf("must not be 名人 without full mastery")
	}
}

func TestComputeMasteryRankClampsOverflow(t *testing.T) {
	streaks := map[int64]int{1: 9, 2: -3}
	r := computeMasteryRank(streaks, []int64{1, 2})
	if r.Mastery != masteryStreakCap {
		t.Fatalf("mastery = %d, want %d (streak clamped)", r.Mastery, masteryStreakCap)
	}
}

func TestComputeMasteryRankIgnoresUnknownQuizzes(t *testing.T) {
	streaks := map[int64]int{1: 2, 999: 2}
	r := computeMasteryRank(streaks, []int64{1, 2, 3})
	if r.Mastery != 2 {
		t.Fatalf("mastery = %d, want 2", r.Mastery)
	}
	if r.TotalPossible != 6 {
		t.Fatalf("totalPossible = %d, want 6", r.TotalPossible)
	}
}
