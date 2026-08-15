---
title: Repo ops
description: Husky, play pads, and docs-example tests borrowed from Zod's repository operations
---

# repo ops (Zod-inspired)

基本設計: [`../INDEX.md`](../INDEX.md)、[`../../AGENTS.md`](../../AGENTS.md)、[`../../CONTRIBUTING.md`](../../CONTRIBUTING.md)

Zod 本体のライブラリ実装は流用しない。流用するのは **同じ PR で docs とテストを直す**、試し書きを `src/` に残さない、エージェント向け手順を文書化する、という運用である。

## エージェント向け正本

| ファイル | 役割 |
| --- | --- |
| [`../../AGENTS.md`](../../AGENTS.md) | 公開契約・置き場・禁止事項 |
| [`../../CLAUDE.md`](../../CLAUDE.md) | AGENTS.md への入口 |
| [`../llms.txt`](../llms.txt) | ページ目録（zod.dev/llms.txt 相当） |
| [`../llms-full.txt`](../llms-full.txt) | 詳細設計の連結（zod.dev/llms-full.txt 相当） |

## 試し書き

| パス | 実行 |
| --- | --- |
| `play.ts`（ルート） | `npm run play`（振る舞い） |
| `scratch/input.ts` | バンドルサイズ（kB）実験の入口。[ADR 0010](../adr/0010-scratch-input-bundle-size.md)。`npm run scratch:measure` |
| `web/scripts/try-quiz-parse.ts` | `cd web && npx --yes tsx scripts/try-quiz-parse.ts` |
| `admin-web/scripts/try-auth-parse.ts` | `cd admin-web && npx --yes tsx scripts/try-auth-parse.ts` |
| `backend/play.go`（`//go:build ignore`） | `cd backend && go run play.go` |

恒久ケースは `tests/` または `*_test.go` へ。`play.local.ts` は gitignore。

## ドキュメント例のテスト

`docs/detailed-design/web/` の fenced TypeScript は `web/tests/contract/docs-examples.test.ts` が実装と fixtures で実行する。例を変えたら実装かテストも同じ差分で直す。ページ追加時は [`writing.md`](./writing.md) に従い `python3 scripts/generate_llms_txt.py` を走らせる。

## フック

- pre-commit: `lint-staged`（ESLint / gofmt / 契約チェック）
- pre-push: `npm run test:contract`

Node は `.nvmrc` の 22。Dependabot が `web/`、`admin-web/`、ルート、`backend/`、GitHub Actions を週次で見る。
