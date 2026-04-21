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

export function generateSessionId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`
}

export function nowIso(): string {
  return new Date().toISOString()
}
