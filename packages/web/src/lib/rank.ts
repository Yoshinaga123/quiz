/**
 * 段位計算 (要件: quiz.md「段位を授与する」)。
 *
 * - 各問題の連続正解数は 0..2 の範囲。上限は 2 (要件どおり)。
 * - 総合的な習熟度 = すべての問題の連続正解数の合計。
 * - 満点 (すべての問題を 2 回連続で解いた) で「名人」。
 * - 満点未満は 13 段階に均等分割し、[4級, 3級, 2級, 1級, 初段..九段] を割り当てる。
 * - 初めてアプリを触るユーザー (streak が空 = 習熟度 0) は「4級」から始まる。
 *
 * 段位は総合的な指標。個別の問題の連続正解数と切り離した pure function にしておく。
 */

export const STREAK_CAP = 2

/**
 * 段位ラベル。低い順から高い順。
 */
export const RANK_LABELS = [
  '4級',
  '3級',
  '2級',
  '1級',
  '初段',
  '二段',
  '三段',
  '四段',
  '五段',
  '六段',
  '七段',
  '八段',
  '九段',
  '名人',
] as const

export type RankLabel = (typeof RANK_LABELS)[number]

const SUB_MASTER_LEVELS = RANK_LABELS.length - 1

export interface RankResult {
  /** 現在の段位ラベル */
  rank: RankLabel
  /** 段位のインデックス (0 = 4級, RANK_LABELS.length - 1 = 名人) */
  index: number
  /** 現在の習熟度 (streak の合計) */
  mastery: number
  /** 満点時の習熟度 (STREAK_CAP × 出題総数) */
  totalPossible: number
  /** 満点比 (0.0..1.0) */
  progress: number
  /** 次の段位ラベル (名人なら null) */
  nextRank: RankLabel | null
  /** 次の段位まで必要な追加習熟度 (名人なら 0) */
  toNextRank: number
}

/**
 * 段位を計算する。
 *
 * @param streaks - quizId -> 直前の連続正解数 (0..STREAK_CAP)。
 * @param quizIds - 集計対象の quizId 一覧。カタログ側で「公開中の全問題」を渡す。
 *                 streaks に存在しない quizId は連続正解数 0 として扱う。
 *                 streaks にあるが quizIds にない (非公開/削除) 問題は集計から外す。
 */
export function computeRank(
  streaks: Readonly<Record<number, number>>,
  quizIds: readonly number[],
): RankResult {
  const totalQuizzes = quizIds.length
  const totalPossible = totalQuizzes * STREAK_CAP

  if (totalPossible === 0) {
    return {
      rank: '4級',
      index: 0,
      mastery: 0,
      totalPossible: 0,
      progress: 0,
      nextRank: RANK_LABELS[1] ?? null,
      toNextRank: 0,
    }
  }

  let mastery = 0
  for (const id of quizIds) {
    const raw = streaks[id]
    if (typeof raw !== 'number') continue
    const clamped = Math.max(0, Math.min(STREAK_CAP, Math.floor(raw)))
    mastery += clamped
  }

  const progress = mastery / totalPossible
  const index = resolveRankIndex(mastery, totalPossible)
  const rank = RANK_LABELS[index] ?? '4級'
  const nextIndex = index + 1
  const nextRank = nextIndex < RANK_LABELS.length ? RANK_LABELS[nextIndex] ?? null : null

  return {
    rank,
    index,
    mastery,
    totalPossible,
    progress,
    nextRank,
    toNextRank: nextRank === null ? 0 : masteryToReachIndex(nextIndex, totalPossible) - mastery,
  }
}

function resolveRankIndex(mastery: number, totalPossible: number): number {
  // 満点は「名人」だけに割り当てる。
  if (mastery >= totalPossible) return RANK_LABELS.length - 1
  // 4級..九段 (13 段階) を 0..totalPossible-1 で均等分割する。
  // ceil で境界を「まだ届いていない」側に倒し、少しでも進歩すれば 3級 に上がるようにする。
  const step = totalPossible / SUB_MASTER_LEVELS
  if (step <= 0) return 0
  const raw = Math.floor(mastery / step)
  return Math.min(SUB_MASTER_LEVELS - 1, Math.max(0, raw))
}

function masteryToReachIndex(index: number, totalPossible: number): number {
  if (index >= RANK_LABELS.length - 1) return totalPossible
  const step = totalPossible / SUB_MASTER_LEVELS
  return Math.ceil(step * index)
}

/**
 * 新しい streak を計算する。要件: 各問題の直前の正解 2 を上限。
 */
export function nextStreak(current: number, isCorrect: boolean): number {
  if (!isCorrect) return 0
  const base = Number.isFinite(current) ? Math.max(0, Math.floor(current)) : 0
  return Math.min(STREAK_CAP, base + 1)
}
