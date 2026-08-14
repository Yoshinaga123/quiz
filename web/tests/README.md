# web/tests

`web/` のユニットテスト。Vitest で実行する（Zod リポジトリと同様、成功・失敗の両方を固定する）。

```bash
cd web
npm test
npm run test:watch
```

設定は [`vitest.config.ts`](./vitest.config.ts)。スキーマの試し書きは [`../scripts/README.md`](../scripts/README.md)。

| ファイル | 対象 | 種別 |
| --- | --- | --- |
| `lib/quizUtils.test.ts` | `src/lib/quizUtils.ts` | ユニット（純粋関数） |
| `lib/historyStorage.test.ts` | `src/lib/historyStorage.ts` | ユニット（DOM・localStorage） |
| `api/client.test.ts` | `src/api/client.ts` | ユニット（fetch / Zod 境界） |
| `schemas/quiz.test.ts` | `src/schemas/quiz.ts` | ユニット（Zod スキーマ） |
| `contract/public-api.test.ts` | `docs/api/fixtures/` | 公開契約（OpenAPI 例を Zod で検証） |

React コンポーネントの統合テストは次フェーズ。
