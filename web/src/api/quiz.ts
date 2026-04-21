import { z } from 'zod';

import { quizzesSchema } from '../schemas/quiz';
import type { Quiz } from '../types/quiz';

import { requestJson } from './client';

/**
 * 公開クイズ API のレスポンス境界。
 * docs/api/public-quiz-api.yaml の `/v1/quizzes` GET と一致させる。
 */
const quizListResponseSchema = z.object({
  quizzes: quizzesSchema,
  totalCount: z.number().int().nonnegative(),
  generatedAt: z.string().min(1),
});

export type QuizListResponse = z.infer<typeof quizListResponseSchema>;

export interface FetchQuizzesParams {
  section?: string;
  limit?: number;
  signal?: AbortSignal;
}

const buildQuery = (params: FetchQuizzesParams): string => {
  const search = new URLSearchParams();
  if (params.section !== undefined && params.section !== '') {
    search.set('section', params.section);
  }
  if (typeof params.limit === 'number' && Number.isInteger(params.limit) && params.limit > 0) {
    search.set('limit', String(params.limit));
  }
  const value = search.toString();
  return value === '' ? '' : `?${value}`;
};

export const fetchQuizzes = async (params: FetchQuizzesParams = {}): Promise<Quiz[]> => {
  const response = await requestJson(
    `/v1/quizzes${buildQuery(params)}`,
    quizListResponseSchema,
    { method: 'GET', signal: params.signal },
  );
  return response.quizzes;
};
