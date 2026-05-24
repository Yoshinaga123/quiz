import { useMemo } from 'react'
import { STARTER_QUIZZES } from '../data/quizzes'
import { quizzesSchema } from '../schemas/quiz'
import type { Quiz } from '../types/quiz'

/**
 * 公開クイズデータの取得エントリポイント。
 *
 * 現状は starter pack を同期で返す。`GET /v1/quizzes` 統合時は
 * このフックを非同期（useEffect + state か SWR 等）に書き直す必要がある。
 * fetchQuizzes() は Promise<Quiz[]> を返すため単純な置換では済まない。
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
