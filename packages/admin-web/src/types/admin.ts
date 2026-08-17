export interface LoginCredentials {
  username: string
  password: string
}

export interface LoginVerificationPayload extends LoginCredentials {
  challengeId: string
  verificationCode: string
}

export interface LoginVerificationChallenge {
  message: string
  challengeId: string
  code?: string | undefined
}

export type QuizStatus = 'published' | 'unpublished'
export type QuizSort = 'updated_newest' | 'updated_oldest' | 'created_newest' | 'created_oldest'

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
  status: QuizStatus
  pushEnabled: boolean
  createdAt: string
  updatedAt: string
}

export interface QuizListResponse {
  items: Quiz[]
  total: number
  page: number
  perPage: number
  totalPages: number
}

export interface ProductionQuizSyncResponse {
  seededCount: number
  deletedCount: number
  source: string
  migrationVersion: number
  upPath: string
  downPath: string
}

export interface PushDispatchResponse {
  deliveryId: number
  quizId: number
  title: string
  channel: 'mock'
  targetCount: number
  status: 'mock_sent'
  sentAt: string
}

export interface PushDelivery {
  deliveryId: number
  quizId: number
  title: string
  channel: string
  targetCount: number
  status: string
  errorDetail?: string | undefined
  sentAt: string
}

export interface PushDeliveryListResponse {
  items: PushDelivery[]
  total: number
  page: number
  perPage: number
  totalPages: number
}

export interface QuizSearchParams {
  title?: string | undefined
  section?: string | undefined
  status?: '' | QuizStatus | undefined
  sort?: QuizSort | undefined
  page?: number | undefined
  per_page?: number | undefined
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
  status: QuizStatus
  pushEnabled: boolean
}

export type QuizFormValues = QuizPayload
