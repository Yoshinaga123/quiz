# web/tests

`web/` 用のテスト雛形を集めるディレクトリ。**現状はテスト実行環境（Vitest）の依存追加が未実施**のため、
ファイルだけ用意してある。実行するには次の追加作業が必要（既存ファイル変更を伴うため別タスク）。

## 有効化手順

1. `web/package.json` に dev 依存を追加する。

   ```jsonc
   {
     "scripts": {
       "test": "vitest run",
       "test:watch": "vitest"
     },
     "devDependencies": {
       "vitest": "^2.1.0",
       "@vitest/coverage-v8": "^2.1.0",
       "@testing-library/react": "^16.0.0",
       "@testing-library/dom": "^10.4.0",
       "@testing-library/jest-dom": "^6.5.0",
       "jsdom": "^25.0.0"
     }
   }
   ```

2. `web/vite.config.ts` の `test` セクションを有効化する（雛形は `vitest.config.ts` を参照）。
3. `npm install && npm run test` で実行。

## 雛形が含むもの

| ファイル | 対象 | 種別 |
| --- | --- | --- |
| `lib/quizUtils.test.ts` | `src/lib/quizUtils.ts` | ユニット（純粋関数） |
| `lib/historyStorage.test.ts` | `src/lib/historyStorage.ts` | ユニット（DOM・localStorage） |
| `api/client.test.ts` | `src/api/client.ts` | ユニット（fetch / Zod 境界） |
| `schemas/quiz.test.ts` | `src/schemas/quiz.ts` | ユニット（Zod スキーマ） |

これらはすべて **副作用に閉じない・依存注入が容易な箇所** にスコープしてある。
React コンポーネントの統合テストは Vitest 導入後の次フェーズで追加する。
