import type { ZodType } from 'zod'
import { z } from 'zod'
import { getAuthToken } from '../auth/session'
import { ApiError } from './errors'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080'

const apiErrorSchema = z.object({
  error: z.string(),
})

interface RequestOptions<T> {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: unknown
  schema: ZodType<T>
  requiresAuth?: boolean
}

interface VoidRequestOptions {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: unknown
  requiresAuth?: boolean
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
}: RequestOptions<T>): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: buildHeaders(body, requiresAuth),
    body: body === undefined ? undefined : JSON.stringify(body),
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
}: VoidRequestOptions): Promise<void> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: buildHeaders(body, requiresAuth),
    body: body === undefined ? undefined : JSON.stringify(body),
  })

  if (!response.ok) {
    throw new ApiError(response.status, await readErrorMessage(response))
  }
}
