import { useMemo } from 'react'
import { STARTER_QUIZZES } from '../data/quizzes'
import { quizzesSchema } from '../schemas/quiz'
import type { Quiz } from '../types/quiz'

/**
 * 公開クイズデータの取得エントリポイント。
 *
 * 現状は starter pack をそのまま返す。バックエンドに `GET /api/quizzes`
 * が追加されたら、ここを fetch + zod 検証に置き換える。
 */
function loadQuizzes(): Quiz[] {
  const parsed = quizzesSchema.safeParse(STARTER_QUIZZES)
  if (!parsed.success) {
    throw new Error('STARTER_QUIZZES is malformed: ' + parsed.error.message)
  }
  return parsed.data
}

export function useQuizCatalog(): readonly Quiz[] {
  return useMemo(() => loadQuizzes(), [])
}
