export interface Quiz {
  id: number
  section: string
  title: string
  question: string
  code?: string | undefined
  options: string[]
  correctAnswerIndex: number
  explanation: string
  source: string
}

export interface QuizAnswer {
  quizId: number
  selectedIndex: number
  correct: boolean
}

export type SessionStatus = 'in_progress' | 'completed'

export interface QuizSession {
  id: string
  sectionFilter: string | null
  total: number
  currentIndex: number
  quizIds: number[]
  answers: QuizAnswer[]
  startedAt: string
  completedAt: string | null
  status: SessionStatus
}

export interface HistoryRecord {
  id: string
  sectionFilter: string | null
  total: number
  correct: number
  startedAt: string
  completedAt: string
  answers: QuizAnswer[]
}

export interface SectionSummary {
  section: string
  count: number
}
