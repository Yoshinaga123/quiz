package main

// 段位 (rank) 計算。packages/web/src/lib/rank.ts / packages/mobile/lib/layers/domain/service/rank.dart と
// 同じロジックの Go 移植。純関数のみ。副作用なし。

const masteryRankSubLevels = 13 // rankLabels の 名人 以外の段数

var masteryRankLabels = [14]string{
	"4級",
	"3級",
	"2級",
	"1級",
	"初段",
	"二段",
	"三段",
	"四段",
	"五段",
	"六段",
	"七段",
	"八段",
	"九段",
	"名人",
}

type masteryRank struct {
	Rank          string  `json:"rank"`
	Index         int     `json:"index"`
	Mastery       int     `json:"mastery"`
	TotalPossible int     `json:"totalPossible"`
	Progress      float64 `json:"progress"`
	NextRank      *string `json:"nextRank"`
	ToNextRank    int     `json:"toNextRank"`
}

// computeMasteryRank は streaks (quiz_id -> 直近連続正解数) と
// 集計対象 quizIds (公開中の全問題) から段位を計算する。
// streaks に存在しない quizId は 0 として扱う。
// streaks にあるが quizIds にない (削除/非公開) 問題は集計外。
func computeMasteryRank(streaks map[int64]int, quizIDs []int64) masteryRank {
	totalPossible := len(quizIDs) * masteryStreakCap
	if totalPossible == 0 {
		var next *string
		if len(masteryRankLabels) > 1 {
			label := masteryRankLabels[1]
			next = &label
		}
		return masteryRank{
			Rank:          masteryRankLabels[0],
			Index:         0,
			Mastery:       0,
			TotalPossible: 0,
			Progress:      0,
			NextRank:      next,
			ToNextRank:    0,
		}
	}

	mastery := 0
	for _, id := range quizIDs {
		v, ok := streaks[id]
		if !ok {
			continue
		}
		if v < 0 {
			v = 0
		}
		if v > masteryStreakCap {
			v = masteryStreakCap
		}
		mastery += v
	}

	index := resolveMasteryRankIndex(mastery, totalPossible)
	rank := masteryRankLabels[index]
	var nextRank *string
	toNextRank := 0
	if next := index + 1; next < len(masteryRankLabels) {
		label := masteryRankLabels[next]
		nextRank = &label
		toNextRank = masteryToReachIndex(next, totalPossible) - mastery
		if toNextRank < 0 {
			toNextRank = 0
		}
	}

	return masteryRank{
		Rank:          rank,
		Index:         index,
		Mastery:       mastery,
		TotalPossible: totalPossible,
		Progress:      float64(mastery) / float64(totalPossible),
		NextRank:      nextRank,
		ToNextRank:    toNextRank,
	}
}

func resolveMasteryRankIndex(mastery, totalPossible int) int {
	if mastery >= totalPossible {
		return len(masteryRankLabels) - 1
	}
	step := float64(totalPossible) / float64(masteryRankSubLevels)
	if step <= 0 {
		return 0
	}
	raw := int(float64(mastery) / step) // floor
	if raw < 0 {
		return 0
	}
	if raw > masteryRankSubLevels-1 {
		return masteryRankSubLevels - 1
	}
	return raw
}

func masteryToReachIndex(index, totalPossible int) int {
	if index >= len(masteryRankLabels)-1 {
		return totalPossible
	}
	step := float64(totalPossible) / float64(masteryRankSubLevels)
	// ceil を int で表現する: (a + b - 1) / b 相当を float で扱う
	v := step * float64(index)
	ceil := int(v)
	if float64(ceil) < v {
		ceil++
	}
	return ceil
}
