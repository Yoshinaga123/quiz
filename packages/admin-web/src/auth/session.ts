import type { NavigateFunction } from 'react-router-dom'
import { ApiError } from '../api/errors'

const TOKEN_STORAGE_KEY = 'quiz-admin-token'

export function getAuthToken(): string | null {
  return window.localStorage.getItem(TOKEN_STORAGE_KEY)
}

export function setAuthToken(token: string): void {
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token)
}

export function clearAuthToken(): void {
  window.localStorage.removeItem(TOKEN_STORAGE_KEY)
}

export function isAuthenticated(): boolean {
  return getAuthToken() !== null
}

export function handleUnauthorized(error: unknown, navigate: NavigateFunction): boolean {
  if (error instanceof ApiError && error.status === 401) {
    clearAuthToken()
    navigate('/login', { replace: true })
    return true
  }

  return false
}
