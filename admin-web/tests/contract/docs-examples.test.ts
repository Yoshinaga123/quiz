import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

import { describe, expect, it } from 'vitest'

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..')

describe('admin-web detailed-design examples', () => {
  const doc = fs.readFileSync(
    path.join(repoRoot, 'docs/detailed-design/admin-web/quiz-schema.md'),
    'utf8',
  )
  const src = fs.readFileSync(path.join(repoRoot, 'admin-web/src/schemas/quiz.ts'), 'utf8')

  it('documents refine and admin-only fields', () => {
    expect(doc).toContain('正解の選択肢を指定してください')
    expect(doc).toContain('status')
    expect(doc).toContain('pushEnabled')
    expect(doc).toContain('publicQuiz')
    expect(src).toContain('.refine(')
    expect(src).toContain('正解の選択肢を指定してください')
  })
})
