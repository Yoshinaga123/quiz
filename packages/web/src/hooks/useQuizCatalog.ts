import { useCallback, useEffect, useMemo, useState } from 'react'
import { getApiBaseUrl } from '../api/client'
import { fetchQuizzes } from '../api/quiz'
import { STARTER_QUIZZES } from '../data/quizzes'
import { quizzesSchema } from '../schemas/quiz'
import type { Quiz } from '../types/quiz'

type QuizCatalogSource = 'starter' | 'api'

export interface QuizCatalogState {
  quizzes: readonly Quiz[]
  isLoading: boolean
  errorMessage: string | null
  source: QuizCatalogSource
  reload: () => void
}

function loadStarterQuizzes(): Quiz[] {
  const parsed = quizzesSchema.safeParse(STARTER_QUIZZES)
  if (!parsed.success) {
    throw new Error('STARTER_QUIZZES is malformed: ' + parsed.error.message)
  }
  return parsed.data
}

export function useQuizCatalog(): QuizCatalogState {
  const starterQuizzes = useMemo(() => loadStarterQuizzes(), [])
  const [quizzes, setQuizzes] = useState<readonly Quiz[]>(starterQuizzes)
  const [isLoading, setIsLoading] = useState(() => getApiBaseUrl() !== null)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [source, setSource] = useState<QuizCatalogSource>('starter')
  const [reloadKey, setReloadKey] = useState(0)

  useEffect(() => {
    if (getApiBaseUrl() === null) {
      return undefined
    }

    const controller = new AbortController()

    fetchQuizzes({ signal: controller.signal })
      .then((items) => {
        if (controller.signal.aborted) return
        setQuizzes(items)
        setSource('api')
      })
      .catch((error: unknown) => {
        if (controller.signal.aborted) return
        setQuizzes(starterQuizzes)
        setSource('starter')
        setErrorMessage(error instanceof Error ? error.message : 'Failed to load quizzes from API')
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          setIsLoading(false)
        }
      })

    return () => controller.abort()
  }, [reloadKey, starterQuizzes])

  const reload = useCallback(() => {
    if (getApiBaseUrl() !== null) {
      setIsLoading(true)
      setErrorMessage(null)
    }
    setReloadKey((current) => current + 1)
  }, [])

  return {
    quizzes,
    isLoading,
    errorMessage,
    source,
    reload,
  }
}
