/**
 * Scratch pad (Zod play.ts equivalent).
 * Do not import this file from web/src or admin-web/src.
 *
 * Run: npm run play
 * Local-only experiments: copy to play.local.ts (gitignored).
 */
import quiz from './docs/api/fixtures/quiz.json' with { type: 'json' }
import { quizSchema } from './web/src/schemas/quiz.ts'

const result = quizSchema.safeParse(quiz)
console.log('success:', result.success)
console.log(result.success ? result.data : result.error)
