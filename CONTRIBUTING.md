# Contributing

このリポジトリはアプリケーションモノレポです。ライブラリの公開 API を増やす作業ではありません。

## 先に読むもの

- [`README.md`](README.md)
- [`docs/INDEX.md`](docs/INDEX.md)
- [`docs/implement-policy.md`](docs/implement-policy.md)
- [`docs/validation-policy.md`](docs/validation-policy.md)

## 開発の流れ

1. プロダクトコードだけを触る（`samples/` や診断教材は原則 PR に含めない）。
2. `gofmt` / `npm run lint` / 対象パッケージのテストを通す。
3. 公開契約を変えたら、実装・スキーマ・ドキュメント・テストを **同じ PR** で直す。

## スキーマ・API を変えるとき

Zod の CONTRIBUTING（実装と docs を同時更新）に合わせる。公開契約の手順は [`docs/detailed-design/web/public-contract.md`](docs/detailed-design/web/public-contract.md)。

| 変更 | 同時に更新する |
| --- | --- |
| 公開 JSON の shape | `docs/api/public-quiz-api.yaml` + `docs/api/fixtures/` + `web/src/schemas/quiz.ts` + `web/src/api/quiz.ts` + `backend/types.go`（`publicQuiz`）+ `web/tests/contract/` + `backend/public_contract_test.go` |
| OpenAPI に書けない業務ルール（`.refine` など） | `docs/detailed-design/web/quiz-schema.md` と `meta.json` |
| 管理画面の入力スキーマ | `admin-web/src/schemas/` + `admin-web/tests/schemas/` |
| なぜ変えたか | 必要なら `docs/adr/` |

試し書きは `web/scripts/`（本番の `src/` に残さない）。

## チェック

```bash
python3 scripts/check_public_contract.py
cd web && npm test && npm run lint && npm run build
cd admin-web && npm test && npm run lint && npm run build
cd backend && gofmt -l . && go test ./... && go vet ./...
npx --yes @redocly/cli lint docs/api/public-quiz-api.yaml
```

## PR

- 1 PR 1 目的。学習用 `samples/` の追加は別リポジトリか `archive/` 方針に従う。
- コミットメッセージは変更理由が分かる短文。
