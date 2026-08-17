import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

import { describe, expect, it } from 'vitest'

import { quizSchema } from '../../src/schemas/quiz'

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../..')

const read = (relative: string): string =>
  fs.readFileSync(path.join(repoRoot, relative), 'utf8')

const readFixture = (name: string): unknown =>
  JSON.parse(read(path.join('docs/api/fixtures', name))) as unknown

const fences = (markdown: string, lang: string): string[] => {
  const blocks: string[] = []
  const pattern = new RegExp('```' + lang + '\\n([\\s\\S]*?)```', 'g')
  for (const match of markdown.matchAll(pattern)) {
    if (match[1]) {
      blocks.push(match[1])
    }
  }
  return blocks
}

const hasFrontmatter = (markdown: string): boolean =>
  markdown.startsWith('---\n') && markdown.includes('\ndescription:')

describe('detailed-design examples', () => {
  const quizSchemaDoc = read('docs/detailed-design/web/quiz-schema.md')
  const basicsDoc = read('docs/detailed-design/web/basics.md')
  const errorDoc = read('docs/detailed-design/web/error-formatting.md')
  const quizSchemaSrc = read('packages/web/src/schemas/quiz.ts')
  const clientSrc = read('packages/web/src/api/client.ts')
  const contractDoc = read('docs/detailed-design/web/public-contract.md')

  it('keeps Zod-style frontmatter on schema pages', () => {
    expect(hasFrontmatter(quizSchemaDoc)).toBe(true)
    expect(hasFrontmatter(basicsDoc)).toBe(true)
    expect(hasFrontmatter(errorDoc)).toBe(true)
    expect(hasFrontmatter(contractDoc)).toBe(true)
  })

  it('documents the refine that quiz.ts implements', () => {
    const blocks = fences(quizSchemaDoc, 'ts')
    expect(blocks.length).toBeGreaterThan(0)
    expect(quizSchemaDoc).toContain('correctAnswerIndex is out of range')
    expect(quizSchemaDoc).toContain('api/fixtures')
    expect(quizSchemaDoc).toContain('public-contract.md')
    expect(quizSchemaSrc).toContain('.refine(')
    expect(quizSchemaSrc).toContain('correctAnswerIndex is out of range')
    expect(quizSchemaSrc).toContain("path: ['correctAnswerIndex']")
  })

  it('runs the documented safeParse / issues flow against fixtures', () => {
    expect(basicsDoc).toContain('quizSchema.safeParse')
    expect(basicsDoc).toContain('z.infer<typeof quizSchema>')
    expect(basicsDoc).toContain("['correctAnswerIndex']")

    const ok = quizSchema.safeParse(readFixture('quiz.json'))
    expect(ok.success).toBe(true)
    if (ok.success) {
      expect(ok.data.id).toBe(1)
    }

    const invalid = quizSchema.safeParse(readFixture('quiz-invalid-answer-index.json'))
    expect(invalid.success).toBe(false)
    if (!invalid.success) {
      expect(invalid.error.issues[0]?.path).toEqual(['correctAnswerIndex'])
    }
  })

  it('documents ApiError wrapping that client.ts implements', () => {
    expect(errorDoc).toContain('schema.safeParse(payload)')
    expect(errorDoc).toContain('ApiError')
    expect(clientSrc).toContain('schema.safeParse(payload)')
    expect(clientSrc).toContain('API response validation failed')
  })

  it('keeps public-contract.md pointing at every sync layer', () => {
    for (const needle of [
      'docs/api/public-quiz-api.yaml',
      'docs/api/fixtures/',
      'packages/web/src/schemas/quiz.ts',
      'packages/backend/types.go',
      'scripts/check_public_contract.py',
      'public_quiz_dto.dart',
    ]) {
      expect(contractDoc).toContain(needle)
    }
  })
})
