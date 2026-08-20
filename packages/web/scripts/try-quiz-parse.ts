/**
 * Zod の play.ts 相当。スキーマの試し書き専用。
 * 本番ビルド（vite build）には含まれない（tsconfig.app.json の include は src のみ）。
 *
 * 恒久ケースは tests/schemas/quiz.test.ts へ。
 *
 * 実行: npx --yes tsx scripts/try-quiz-parse.ts
 */
import { quizzesSchema } from '../src/schemas/quiz.ts'
import { STARTER_QUIZZES } from '../src/data/quizzes.ts'

const result = quizzesSchema.safeParse(STARTER_QUIZZES)
console.log('success:', result.success)
console.log(result.success ? result.data : result.error)

// cd packages/web && npx --yes tsx scripts/try-quiz-parse.ts