# Contributing

このリポジトリはアプリケーションモノレポです。ライブラリの公開 API を増やす作業ではありません。  
行動規範は [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)。エージェント向け手順は [`AGENTS.md`](AGENTS.md)。

## 先に読むもの

- [`README.md`](README.md)
- [`docs/INDEX.md`](docs/INDEX.md)
- [`docs/implement-policy.md`](docs/implement-policy.md)
- [`docs/validation-policy.md`](docs/validation-policy.md)
- [`docs/detailed-design/repo-ops.md`](docs/detailed-design/repo-ops.md)

## 開発の流れ

1. プロダクトコードだけを触る（`samples/` や診断教材は原則 PR に含めない）。
2. ルートで `npm i` したあと `npm test` / `npm run lint` を通す（Node 22、`.nvmrc`。workspaces）。
3. 公開契約を変えたら、実装・スキーマ・ドキュメント・テストを **同じ PR** で直す。
4. 詳細設計の fenced TypeScript を変えたら、`packages/web/tests/contract/docs-examples.test.ts` も同じ差分で直す。
5. 詳細設計のページを足したら frontmatter（`title` / `description`）と `meta.json`（ルートとパッケージフォルダ）を更新し、`npm run docs:llms` を走らせる。書き方は [`docs/detailed-design/writing.md`](docs/detailed-design/writing.md)。

Husky が commit 前に lint-staged、push 前に `npm run test:contract` を走らせる。

<!-- auto-merge smoke #2 ran 2026-08-20 -->

## スキーマ・API を変えるとき

Zod の CONTRIBUTING（実装と docs を同時更新）に合わせる。公開契約の手順は [`docs/detailed-design/web/public-contract.md`](docs/detailed-design/web/public-contract.md)。

| 変更 | 同時に更新する |
| --- | --- |
| 公開 JSON の shape | `docs/api/public-quiz-api.yaml` + `docs/api/fixtures/` + `packages/web/src/schemas/quiz.ts` + `packages/web/src/api/quiz.ts` + `packages/backend/types.go`（`publicQuiz`）+ `packages/web/tests/contract/` + `packages/backend/public_contract_test.go` + mobile DTO |
| OpenAPI に書けない業務ルール（`.refine` など） | `docs/detailed-design/web/quiz-schema.md` と `meta.json` |
| 管理画面の入力スキーマ | `packages/admin-web/src/schemas/` + `packages/admin-web/tests/schemas/` + `docs/detailed-design/admin-web/quiz-schema.md` |
| なぜ変えたか | 必要なら `docs/adr/` |

試し書きは `play.ts`、`packages/web/scripts/`、`packages/admin-web/scripts/`、`packages/backend/play.go`（本番の `src/` に残さない）。

## チェック

```bash
npm test
npm run lint
npm run check:circular
npm run check:docs
npx --yes @redocly/cli lint docs/api/public-quiz-api.yaml
```

個別パッケージ:

```bash
python3 scripts/check_public_contract.py
python3 scripts/check_repo_hygiene.py
cd packages/web && npm test && npm run lint && npm run build
cd packages/admin-web && npm test && npm run lint && npm run build
cd packages/backend && gofmt -l . && go test ./... && go vet ./...
```

## PR

- 1 PR 1 目的。学習用 `samples/` の追加は別リポジトリか `archive/` 方針に従う。
- コミットメッセージは変更理由が分かる短文。
- 公開契約を変える Issue は `.github/ISSUE_TEMPLATE/contract.yml` を使う。
- `develop` / `main` 以外への push は [`.github/workflows/auto-pr-merge.yml`](.github/workflows/auto-pr-merge.yml) が **PR を自動作成**し、draft でなければ **auto-merge を有効化**する。必須 CI が緑なら `develop` へ自動マージされる。コンフリクトや未解決レビュー会話がある場合は止まって人手待ち。
- 手元で明示する場合: `gh pr create --base develop` のあと `gh pr merge --auto --merge`。
