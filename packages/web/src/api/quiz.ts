import { z } from 'zod';
// Zod は TypeScript/JavaScript でデータ構造（スキーマ）を定義し、実行時のデータ検証と TypeScript の型推論を同時に行うライブラリ。
// 型定義と実行時の処理をSingle Source of Truthとして管理できる。

import { quizzesSchema } from '../schemas/quiz';
// 
import type { Quiz } from '../types/quiz';

import { requestJson } from './client';

/**
 * 公開クイズ API のレスポンス境界。
 * docs/api/public-quiz-api.yaml の `/v1/quizzes` GET と一致させる。
 */
export const quizListResponseSchema = z.object({
  quizzes: quizzesSchema,
  totalCount: z.number().int().nonnegative(),
  generatedAt: z.string().min(1),
});

export type QuizListResponse = z.infer<typeof quizListResponseSchema>;

export interface FetchQuizzesParams {
  section?: string | undefined;
  limit?: number | undefined;
  signal?: AbortSignal | undefined;
}

const buildQuery = (params: FetchQuizzesParams): string => {
  const search = new URLSearchParams();
  if (params.section !== undefined && params.section !== '') {
    search.set('section', params.section);
  }
  if (
    typeof params.limit === 'number' &&
    Number.isInteger(params.limit) &&
    params.limit >= 1 &&
    params.limit <= 100
  ) {
    search.set('limit', String(params.limit));
  }
  const value = search.toString();
  return value === '' ? '' : `?${value}`;
};

export const fetchQuizzes = async (params: FetchQuizzesParams = {}): Promise<Quiz[]> => {
  const response = await requestJson(
    `/v1/quizzes${buildQuery(params)}`,
    quizListResponseSchema,
    {
      method: 'GET',
      ...(params.signal !== undefined ? { signal: params.signal } : {}),
    },
  );
  return response.quizzes;
};
