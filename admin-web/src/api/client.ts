import type { ZodType } from 'zod'
import { z } from 'zod'
import { getAuthToken } from '../auth/session'
import { ApiError } from './errors'

const API_BASE_URL = 'http://localhost:8082'

const apiErrorSchema = z.object({
  error: z.string(),
})

interface RequestOptions<T> {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  body?: unknown
  schema: ZodType<T>
  requiresAuth?: boolean
  signal?: AbortSignal
}

interface VoidRequestOptions {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  body?: unknown
  requiresAuth?: boolean
  signal?: AbortSignal
}

function buildHeaders(body: unknown, requiresAuth: boolean): Headers {
  const headers = new Headers()

  if (body !== undefined) {
    headers.set('Content-Type', 'application/json')
  }

  if (requiresAuth) {
    const token = getAuthToken()
    if (token) {
      headers.set('Authorization', `Bearer ${token}`)
    }
  }

  return headers
}

async function readErrorMessage(response: Response): Promise<string> {
  try {
    const json: unknown = await response.json()
    const parsed = apiErrorSchema.safeParse(json)
    if (parsed.success) {
      return parsed.data.error
    }
  } catch {
    return `Request failed with status ${response.status}`
  }

  return `Request failed with status ${response.status}`
}

export async function requestJson<T>({
  path,
  method = 'GET',
  body,
  schema,
  requiresAuth = true,
  signal,
}: RequestOptions<T>): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: buildHeaders(body, requiresAuth),
    body: body === undefined ? undefined : JSON.stringify(body),
    signal,
  })

  if (!response.ok) {
    throw new ApiError(response.status, await readErrorMessage(response))
  }

  const json: unknown = await response.json()
  const parsed = schema.safeParse(json)
  if (!parsed.success) {
    throw new Error('Invalid API response format')
  }

  return parsed.data
}

export async function requestVoid({
  path,
  method = 'DELETE',
  body,
  requiresAuth = true,
  signal,
}: VoidRequestOptions): Promise<void> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: buildHeaders(body, requiresAuth),
    body: body === undefined ? undefined : JSON.stringify(body),
    signal,
  })

  if (!response.ok) {
    throw new ApiError(response.status, await readErrorMessage(response))
  }
}
