import useSWR from 'swr'
import { listQuizzes } from '../api/admin'
import type { QuizListResponse, QuizSearchParams } from '../types/admin'

export function useQuizzes(params?: QuizSearchParams) {
  const cacheKey = ['/api/admin/quizzes', params] as const

  const { data, error, isLoading, mutate } = useSWR<QuizListResponse>(
    cacheKey,
    () => listQuizzes(params),
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: true,
    },
  )

  return {
    quizzes: data?.items ?? [],
    total: data?.total ?? 0,
    page: data?.page ?? 1,
    perPage: data?.perPage ?? 20,
    totalPages: data?.totalPages ?? 0,
    error,
    errorMessage: error instanceof Error ? error.message : null,
    isLoading,
    mutate,
  }
}
