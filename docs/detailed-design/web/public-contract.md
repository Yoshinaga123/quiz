---
title: public API contract sync
description: Same-PR checklist for OpenAPI, fixtures, Zod, Go publicQuiz, detailed design, and tests
---

# public API contract sync

基本設計: [`../../api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)、[`../../adr/0006-public-quiz-api.md`](../../adr/0006-public-quiz-api.md)

公開 JSON の shape を変えたら、**同じ PR** で次を全部直す。

| 層 | パス |
| --- | --- |
| 契約 | `docs/api/public-quiz-api.yaml` |
| 例（実行時 SSOT） | `docs/api/fixtures/` |
| Zod | `packages/web/src/schemas/quiz.ts`、`packages/web/src/api/quiz.ts` |
| 実装 | `packages/backend/types.go` の `publicQuiz` / `public.go` |
| 詳細設計 | このファイルと [`quiz-schema.md`](./quiz-schema.md)（`.refine`） |
| テスト | `packages/web/tests/contract/`、`packages/backend/public_contract_test.go`、`scripts/check_public_contract.py` |
| モバイル | `packages/mobile/lib/layers/data/dto/public_quiz_dto.dart` |

## コマンド

```bash
npm run test:contract
```

個別: `python3 scripts/check_public_contract.py`、`cd packages/web && npm test`、`cd packages/backend && go test ./... -count=1`。

CI: `.github/workflows/public-contract.yml` と `.github/workflows/quality.yml`。

## 一覧のページング

`GET /v1/quizzes` は `limit`（1..100、未指定時 100）と `offset`（0 始まり、未指定時 0）を受け取る。
レスポンスの JSON shape は変えない（`quizzes` / `totalCount` / `generatedAt`）。
`totalCount` は今のページではなく、条件に合う公開クイズの全件数。

1 回の応答は最大 100 件なので、100 件を超える公開データを取るときは `offset` を進める。
web の `fetchQuizzes` と mobile の `fetchQuizList` は、呼び出し側が `limit` / `offset` を付けないとき、全ページを辿ってカタログを揃える。
