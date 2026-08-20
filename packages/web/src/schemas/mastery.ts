import { z } from 'zod'

// v1: 各 quizId ごとの「直前の連続正解数」を 0..2 で保持する。 2 が上限（要件: 各問題の直前の正解 2 を上限）。 誤答したら 0 にリセット、正解したら min(current+1, 2)。
export const masteryStateSchema = z.object({
  streaks: z.record(z.string(), z.number().int().min(0).max(2)),
  updatedAt: z.string().datetime({ offset: true }),
})

export type MasteryState = z.infer<typeof masteryStateSchema>
