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
| Zod | `web/src/schemas/quiz.ts`、`web/src/api/quiz.ts` |
| 実装 | `backend/types.go` の `publicQuiz` / `public.go` |
| 詳細設計 | このファイルと [`quiz-schema.md`](./quiz-schema.md)（`.refine`） |
| テスト | `web/tests/contract/`、`backend/public_contract_test.go`、`scripts/check_public_contract.py` |
| モバイル | `mobile/lib/layers/data/dto/public_quiz_dto.dart` |

## コマンド

```bash
npm run test:contract
```

個別: `python3 scripts/check_public_contract.py`、`cd web && npm test`、`cd backend && go test ./... -count=1`。

CI: `.github/workflows/public-contract.yml` と `.github/workflows/quality.yml`。
