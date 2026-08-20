import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { fetchQuizzes } from '../../src/api/quiz';

const sampleQuiz = {
  id: 1,
  section: 'React',
  title: 'useState',
  question: 'What does useState return?',
  code: 'const [value, setValue] = useState(0);',
  options: ['array', 'object'],
  correctAnswerIndex: 0,
  explanation: 'It returns a tuple [state, setState].',
  source: 'https://react.dev/reference/react/useState',
};

const listBody = (quizzes: unknown[], totalCount: number): string =>
  JSON.stringify({
    quizzes,
    totalCount,
    generatedAt: '2026-01-15T10:30:00.000Z',
  });

beforeEach(() => {
  vi.stubEnv('VITE_API_BASE_URL', 'https://api.test');
});

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllEnvs();
});

describe('fetchQuizzes', () => {
  it('walks offset pages until totalCount is covered', async () => {
    const firstPage = Array.from({ length: 100 }, (_, index) => ({
      ...sampleQuiz,
      id: index + 1,
    }));
    const secondPage = Array.from({ length: 5 }, (_, index) => ({
      ...sampleQuiz,
      id: index + 101,
    }));

    const fetchMock = vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.includes('offset=100')) {
        return new Response(listBody(secondPage, 105), {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
        });
      }
      return new Response(listBody(firstPage, 105), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    });
    globalThis.fetch = fetchMock;

    const quizzes = await fetchQuizzes();

    expect(quizzes).toHaveLength(105);
    expect(quizzes[0]?.id).toBe(1);
    expect(quizzes[104]?.id).toBe(105);
    expect(fetchMock).toHaveBeenCalledTimes(2);
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain('limit=100');
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain('offset=0');
    expect(String(fetchMock.mock.calls[1]?.[0])).toContain('offset=100');
  });

  it('sends a single page when limit is set', async () => {
    const fetchMock = vi.fn(async (_input: RequestInfo | URL) =>
      new Response(listBody([sampleQuiz], 200), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }),
    );
    globalThis.fetch = fetchMock;

    const quizzes = await fetchQuizzes({ limit: 1, offset: 20 });

    expect(quizzes).toHaveLength(1);
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain('limit=1');
    expect(String(fetchMock.mock.calls[0]?.[0])).toContain('offset=20');
  });
});
