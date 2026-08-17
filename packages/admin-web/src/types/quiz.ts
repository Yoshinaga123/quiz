/**
 * クイズデータ型定義
 * src/data/quizzes.json の構造を定義
 */

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

export interface QuizzesData {
  quizzes: Quiz[]
}

/**
 * クイズの詳細情報を含む型（フロントエンド表示用）
 */
export interface QuizWithAnswer extends Quiz {
  userAnswer?: number | null | undefined
  isCorrect?: boolean | undefined
}

/**
 * クイズセッション管理用
 */
export interface QuizSession {
  totalQuizzes: number
  currentQuizIndex: number
  score: number
  answeredQuizzes: Map<number, number> // quizId -> userAnswerIndex
  startedAt: Date
  completedAt?: Date | undefined
}

/**
 * クイズの統計情報
 */
export interface QuizStatistics {
  totalAttempts: number
  correctAnswers: number
  incorrectAnswers: number
  averageScore: number
  sections: SectionStatistics[]
}

export interface SectionStatistics {
  sectionName: string
  quizCount: number
  correctCount: number
  accuracy: number
}
