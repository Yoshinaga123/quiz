import type { ZodType } from 'zod'
import { z } from 'zod'
import { getAuthToken } from '../auth/session'
import { ApiError } from './errors'

const trimSlash = (value: string): string => value.replace(/\/+$/u, '')

const getApiBaseUrl = (): string => {
  const raw = import.meta.env.VITE_API_BASE_URL
  if (typeof raw !== 'string' || raw.trim() === '') {
    return ''
  }

  return trimSlash(raw.trim())
}

export const buildApiUrl = (path: string): string => {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`
  return `${getApiBaseUrl()}${normalizedPath}`
}

const apiErrorSchema = z.object({
  error: z.string(),
})

interface RequestOptions<T> {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  body?: unknown
  schema: ZodType<T>
  requiresAuth?: boolean
  signal?: AbortSignal | undefined
}

interface VoidRequestOptions {
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  body?: unknown
  requiresAuth?: boolean
  signal?: AbortSignal | undefined
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
  const init: RequestInit = {
    method,
    headers: buildHeaders(body, requiresAuth),
  }
  if (body !== undefined) {
    init.body = JSON.stringify(body)
  }
  if (signal !== undefined) {
    init.signal = signal
  }

  const response = await fetch(buildApiUrl(path), init)

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
  const init: RequestInit = {
    method,
    headers: buildHeaders(body, requiresAuth),
  }
  if (body !== undefined) {
    init.body = JSON.stringify(body)
  }
  if (signal !== undefined) {
    init.signal = signal
  }

  const response = await fetch(buildApiUrl(path), init)

  if (!response.ok) {
    throw new ApiError(response.status, await readErrorMessage(response))
  }
}
