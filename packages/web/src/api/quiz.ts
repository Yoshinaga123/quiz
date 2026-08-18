import { z } from 'zod';
// Zod は TypeScript/JavaScript でデータ構造（スキーマ）を定義し、実行時のデータ検証と TypeScript の型推論を同時に行うライブラリ。
// 型定義と実行時の処理をSingle Source of Truthとして管理できる。

import { quizzesSchema } from '../schemas/quiz';
// 
import type { HistoryRecord, Quiz } from '../types/quiz';

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

export const attemptAnswerSchema = z.object({
  quizId: z.number().int().positive(),
  selectedIndex: z.number().int().nonnegative(),
  isCorrect: z.boolean(),
  answeredAt: z.string().min(1).optional(),
});

export const attemptCreateRequestSchema = z.object({
  clientSessionId: z.string().uuid(),
  completedAt: z.string().min(1),
  section: z.string().min(1).optional(),
  answers: z.array(attemptAnswerSchema).min(1),
});

export const attemptAcceptedSchema = z.object({
  clientSessionId: z.string().min(1),
  status: z.literal('accepted'),
});

export type AttemptCreateRequest = z.infer<typeof attemptCreateRequestSchema>;
export type AttemptAccepted = z.infer<typeof attemptAcceptedSchema>;

export const historyRecordToAttempt = (record: HistoryRecord): AttemptCreateRequest => {
  const request: AttemptCreateRequest = {
    clientSessionId: record.id,
    completedAt: record.completedAt,
    answers: record.answers.map((answer) => ({
      quizId: answer.quizId,
      selectedIndex: answer.selectedIndex,
      isCorrect: answer.correct,
    })),
  };
  if (record.sectionFilter !== null && record.sectionFilter !== '') {
    request.section = record.sectionFilter;
  }
  return request;
};

export const submitAttempt = async (record: HistoryRecord): Promise<AttemptAccepted> =>
  requestJson('/v1/attempts', attemptAcceptedSchema, {
    method: 'POST',
    body: historyRecordToAttempt(record),
  });

export const submitAttemptBestEffort = async (record: HistoryRecord): Promise<void> => {
  try {
    await submitAttempt(record);
  } catch {
    // localStorage remains the primary history source
  }
};
