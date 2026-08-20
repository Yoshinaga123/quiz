import type { Quiz, SectionSummary } from '../types/quiz'

export function listSections(quizzes: readonly Quiz[]): SectionSummary[] {
  const counts = new Map<string, number>()
  for (const quiz of quizzes) {
    counts.set(quiz.section, (counts.get(quiz.section) ?? 0) + 1)
  }
  return Array.from(counts.entries())
    .map(([section, count]) => ({ section, count }))
    .sort((a, b) => a.section.localeCompare(b.section, 'ja'))
}

export function filterBySection(
  quizzes: readonly Quiz[],
  section: string | null,
): Quiz[] {
  if (section === null || section === '') {
    return [...quizzes]
  }
  return quizzes.filter((quiz) => quiz.section === section)
}

export function shuffle<T>(items: readonly T[]): T[] {
  const next = [...items]
  for (let i = next.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    const tmp = next[i] as T
    next[i] = next[j] as T
    next[j] = tmp
  }
  return next
}

export function pickQuizIds(
  quizzes: readonly Quiz[],
  section: string | null,
  limit: number,
): number[] {
  const pool = filterBySection(quizzes, section)
  const shuffled = shuffle(pool)
  return shuffled.slice(0, Math.max(0, Math.min(limit, shuffled.length))).map((quiz) => quiz.id)
}

export function findQuiz(quizzes: readonly Quiz[], id: number): Quiz | undefined {
  return quizzes.find((quiz) => quiz.id === id)
}

export function isAnswerCorrect(quiz: Quiz, selectedIndex: number): boolean {
  return quiz.correctAnswerIndex === selectedIndex
}

export function calculateAccuracy(correct: number, total: number): number {
  if (total <= 0) return 0
  return Math.round((correct / total) * 100)
}

// The public attempts API requires a UUID, but `crypto.randomUUID` only exists in secure contexts, so plain-HTTP hosts fall back to `getRandomValues`.
export function generateSessionId(): string {
  const webCrypto = globalThis.crypto as Crypto | undefined
  if (typeof webCrypto?.randomUUID === 'function') {
    return webCrypto.randomUUID()
  }
  return uuidV4FromBytes(randomBytes(16))
}

function randomBytes(length: number): Uint8Array {
  const bytes = new Uint8Array(length)
  const webCrypto = globalThis.crypto as Crypto | undefined
  if (typeof webCrypto?.getRandomValues === 'function') {
    webCrypto.getRandomValues(bytes)
    return bytes
  }
  for (let i = 0; i < length; i++) {
    bytes[i] = Math.floor(Math.random() * 256)
  }
  return bytes
}

function uuidV4FromBytes(bytes: Uint8Array): string {
  bytes[6] = ((bytes[6] as number) & 0x0f) | 0x40
  bytes[8] = ((bytes[8] as number) & 0x3f) | 0x80
  const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('')
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    hex.slice(12, 16),
    hex.slice(16, 20),
    hex.slice(20, 32),
  ].join('-')
}

export function nowIso(): string {
  return new Date().toISOString()
}
