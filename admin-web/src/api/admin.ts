import { loginRequestSchema, loginResponseSchema } from '../schemas/auth'
import { quizPayloadSchema, quizSchema, quizzesSchema } from '../schemas/quiz'
import type { LoginCredentials, Quiz, QuizPayload } from '../types/admin'
import { requestJson, requestVoid } from './client'

export async function login(credentials: LoginCredentials): Promise<string> {
  const payload = loginRequestSchema.parse(credentials)
  const response = await requestJson({
    path: '/api/admin/login',
    method: 'POST',
    body: payload,
    schema: loginResponseSchema,
    requiresAuth: false,
  })

  return response.token
}

export async function listQuizzes(): Promise<Quiz[]> {
  return requestJson({
    path: '/api/admin/quizzes',
    schema: quizzesSchema,
  })
}

export async function getQuiz(id: number | string): Promise<Quiz> {
  return requestJson({
    path: `/api/admin/quizzes/${id}`,
    schema: quizSchema,
  })
}

export async function createQuiz(payload: QuizPayload): Promise<Quiz> {
  const parsedPayload = quizPayloadSchema.parse(payload)

  return requestJson({
    path: '/api/admin/quizzes',
    method: 'POST',
    body: parsedPayload,
    schema: quizSchema,
  })
}

export async function updateQuiz(id: number | string, payload: QuizPayload): Promise<Quiz> {
  const parsedPayload = quizPayloadSchema.parse(payload)

  return requestJson({
    path: `/api/admin/quizzes/${id}`,
    method: 'PUT',
    body: parsedPayload,
    schema: quizSchema,
  })
}

export async function deleteQuiz(id: number | string): Promise<void> {
  await requestVoid({
    path: `/api/admin/quizzes/${id}`,
    method: 'DELETE',
  })
}
