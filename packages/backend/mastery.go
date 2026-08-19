package main

import (
	"context"
	"net/http"
	"sort"
	"time"
)

// ADR 0018 系のフォローアップ:
// answer_history から streak (直近の連続正解数, 上限 2) を都度導出する。
// quizzes.correct_answer_index との JOIN で「正解が後から訂正された」場合に
// 過去の履歴の正誤判定に自動追従する (ADR 0016 §4)。
// 集計対象は公開中 (status = 'published') のクイズだけ。非公開・削除は自動で外れる。

const masteryStreakCap = 2

type masteryEntry struct {
	QuizID int64 `json:"quizId"`
	Streak int   `json:"streak"`
}

type masteryResponse struct {
	Items     []masteryEntry `json:"items"`
	StreakCap int            `json:"streakCap"`
	Rank      masteryRank    `json:"rank"`
}

func (s *server) handleGetMemberMastery(w http.ResponseWriter, r *http.Request) {
	memberID, ok := memberIDFromContext(r.Context())
	if !ok {
		writePublicError(w, http.StatusUnauthorized, publicErrCodeUnauthorized, "no member context")
		return
	}

	// 集計対象の公開クイズ ID 一覧。段位の totalPossible の分母になる。
	publishedIDs, err := s.listPublishedQuizIDs(r.Context())
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load quiz catalog")
		return
	}

	rows, err := s.db.QueryContext(
		r.Context(),
		`SELECT ah.quiz_id,
		        (ah.selected_index = q.correct_answer_index) AS is_correct,
		        ah.answered_at
		 FROM answer_history ah
		 JOIN quizzes q ON q.id = ah.quiz_id
		 WHERE ah.member_id = $1
		 ORDER BY ah.quiz_id ASC, ah.answered_at ASC, ah.id ASC`,
		memberID,
	)
	if err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to load answer history")
		return
	}
	defer rows.Close()

	streaks := make(map[int64]int)
	current := make(map[int64]int)
	for rows.Next() {
		var (
			quizID    int64
			isCorrect bool
			answered  time.Time
		)
		if err := rows.Scan(&quizID, &isCorrect, &answered); err != nil {
			writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to scan history row")
			return
		}
		if isCorrect {
			next := current[quizID] + 1
			if next > masteryStreakCap {
				next = masteryStreakCap
			}
			current[quizID] = next
		} else {
			current[quizID] = 0
		}
		streaks[quizID] = current[quizID]
	}
	if err := rows.Err(); err != nil {
		writePublicError(w, http.StatusInternalServerError, publicErrCodeInternal, "failed to iterate history")
		return
	}

	items := make([]masteryEntry, 0, len(streaks))
	for id, streak := range streaks {
		items = append(items, masteryEntry{QuizID: id, Streak: streak})
	}
	sort.Slice(items, func(i, j int) bool { return items[i].QuizID < items[j].QuizID })

	rank := computeMasteryRank(streaks, publishedIDs)

	writeJSON(w, http.StatusOK, masteryResponse{
		Items:     items,
		StreakCap: masteryStreakCap,
		Rank:      rank,
	})
}

func (s *server) listPublishedQuizIDs(ctx context.Context) ([]int64, error) {
	rows, err := s.db.QueryContext(
		ctx,
		`SELECT id FROM quizzes WHERE status = 'published' ORDER BY id ASC`,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	ids := make([]int64, 0, 64)
	for rows.Next() {
		var id int64
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}
