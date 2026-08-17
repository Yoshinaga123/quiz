# packages/web/scripts

Zod リポジトリの [`play.ts`](https://github.com/colinhacks/zod/blob/main/play.ts) 相当。  
スキーマや fetch の試し書きはここに置く。`src/` には残さない（vite build の include は `src` のみ）。  
リポジトリ全体の試し書きはルートの `play.ts`（`npm run play`）。

| ファイル | 用途 |
| --- | --- |
| `try-quiz-parse.ts` | `quizzesSchema.safeParse(STARTER_QUIZZES)` の手動確認 |

```bash
cd packages/web
npx --yes tsx scripts/try-quiz-parse.ts
```

恒久的な成功・失敗ケースは `tests/schemas/quiz.test.ts` に書く。`npm run test` で実行する。
