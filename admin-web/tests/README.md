# admin-web/tests

`admin-web/` のユニットテスト。Vitest で実行する（成功・失敗の両方を固定する）。

```bash
cd admin-web
npm test
npm run test:watch
```

設定は [`vitest.config.ts`](./vitest.config.ts)。

| ファイル | 対象 |
| --- | --- |
| `schemas/quiz.test.ts` | `src/schemas/quiz.ts` |
| `schemas/auth.test.ts` | `src/schemas/auth.ts` |
| `lib/quizUtils.test.ts` | `isAnswerCorrect` / `enrichQuizWithAnswer` |
