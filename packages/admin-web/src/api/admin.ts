import {
  loginRequestSchema,
  loginResponseSchema,
  loginChallengeResponseSchema,
  loginVerificationSchema,
} from '../schemas/auth'
import {
  productionQuizSyncResponseSchema,
  quizListResponseSchema,
  quizPayloadSchema,
  quizSchema,
} from '../schemas/quiz'
import {
  pushDeliveryListResponseSchema,
  pushDispatchResponseSchema,
} from '../schemas/push'
import type {
  LoginCredentials,
  ProductionQuizSyncResponse,
  LoginVerificationChallenge,
  LoginVerificationPayload,
  PushDeliveryListResponse,
  PushDispatchResponse,
  Quiz,
  QuizListResponse,
  QuizPayload,
  QuizSearchParams,
} from '../types/admin'
import { requestJson, requestVoid } from './client'

export async function requestLoginVerification(
  credentials: LoginCredentials
): Promise<LoginVerificationChallenge> {
  const payload = loginRequestSchema.parse(credentials)
  return requestJson({
    path: '/api/admin/login/verification',
    method: 'POST',
    body: payload,
    schema: loginChallengeResponseSchema,
    requiresAuth: false,
  })
}

export async function login(payload: LoginVerificationPayload): Promise<string> {
  const body = loginVerificationSchema.parse(payload)
  const response = await requestJson({
    path: '/api/admin/login',
    method: 'POST',
    body,
    schema: loginResponseSchema,
    requiresAuth: false,
  })

  return response.token
}

export async function listQuizzes(params?: QuizSearchParams): Promise<QuizListResponse> {
  const searchParams = new URLSearchParams()
  if (params?.title) searchParams.set('title', params.title)
  if (params?.section) searchParams.set('section', params.section)
  if (params?.status) searchParams.set('status', params.status)
  if (params?.sort) searchParams.set('sort', params.sort)
  if (params?.page) searchParams.set('page', String(params.page))
  if (params?.per_page) searchParams.set('per_page', String(params.per_page))

  const query = searchParams.toString()
  const path = query ? `/api/admin/quizzes?${query}` : '/api/admin/quizzes'

  return requestJson({
    path,
    schema: quizListResponseSchema,
  })
}

export async function getQuiz(id: number | string, signal?: AbortSignal): Promise<Quiz> {
  return requestJson({
    path: `/api/admin/quizzes/${id}`,
    schema: quizSchema,
    signal,
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

export async function toggleQuizStatus(id: number | string): Promise<Quiz> {
  return requestJson({
    path: `/api/admin/quizzes/${id}/status`,
    method: 'PATCH',
    schema: quizSchema,
  })
}

export async function toggleQuizPush(id: number | string): Promise<Quiz> {
  return requestJson({
    path: `/api/admin/quizzes/${id}/push`,
    method: 'PATCH',
    schema: quizSchema,
  })
}

export async function syncProductionQuizzes(): Promise<ProductionQuizSyncResponse> {
  return requestJson({
    path: '/api/admin/quizzes/sync-production',
    method: 'POST',
    schema: productionQuizSyncResponseSchema,
  })
}

export async function dispatchMockPush(): Promise<PushDispatchResponse> {
  return requestJson({
    path: '/api/admin/push/dispatch',
    method: 'POST',
    schema: pushDispatchResponseSchema,
  })
}

export async function fetchPushDeliveries(): Promise<PushDeliveryListResponse> {
  return requestJson({
    path: '/api/admin/push/deliveries',
    schema: pushDeliveryListResponseSchema,
  })
}
