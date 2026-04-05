export interface LoginCredentials {
  username: string
  password: string
}

export interface Quiz {
  id: number
  section: string
  title: string
  question: string
  code?: string
  options: string[]
  correctAnswerIndex: number
  explanation: string
  source: string
  createdAt: string
  updatedAt: string
}

export interface QuizPayload {
  section: string
  title: string
  question: string
  code: string
  options: string[]
  correctAnswerIndex: number
  explanation: string
  source: string
}

export type QuizFormValues = QuizPayload
