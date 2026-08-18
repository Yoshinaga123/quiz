---
title: Repo ops
description: Husky, play pads, Dev Container runtimes, and docs-example tests borrowed from Zod's repository operations
---

# repo ops (Zod-inspired)

基本設計: [`../INDEX.md`](../INDEX.md)、[`../../AGENTS.md`](../../AGENTS.md)、[`../../CONTRIBUTING.md`](../../CONTRIBUTING.md)

Zod 本体のライブラリ実装は流用しない。流用するのは **同じ PR で docs とテストを直す**、試し書きを `src/` に残さない、エージェント向け手順を文書化する、という運用である。

## エージェント向け正本

| ファイル | 役割 |
| --- | --- |
| [`../../AGENTS.md`](../../AGENTS.md) | 正本。公開契約・Rules・Do not。調査は triage スキル、公開レビューは `## Code Review Rules` |
| [`../../.claude/skills/triage/SKILL.md`](../../.claude/skills/triage/SKILL.md) | Issue / PR 調査。Codex は `.codex/skills` → `.claude/skills`。メモは gitignore の `.triage/` |
| [`../../.gitignore`](../../.gitignore) | Zod と同じ `scratch` / `.triage/` / `tmp/`。加えて `samples/` と Firebase 設定 |
| [`../../CLAUDE.md`](../../CLAUDE.md) | AGENTS.md への入口 |
| [`../llms.txt`](../llms.txt) | ページ目録（zod.dev/llms.txt 相当） |
| [`../llms-full.txt`](../llms-full.txt) | 詳細設計の連結（zod.dev/llms-full.txt 相当） |

## 試し書き

| パス | 実行 |
| --- | --- |
| `play.ts`（ルート） | `npm run play`（振る舞い） |
| 手元の `scratch/input.ts`（gitignore） | バンドルサイズ（kB）実験。[ADR 0010](../adr/0010-scratch-input-bundle-size.md)。道具は `scripts/scratch-measure.mjs`。`npm run scratch:measure` |
| `packages/bench/` | 実行速度（ops/sec）。[ADR 0013](../adr/0013-runtime-bench.md)。`npm run bench` |
| `packages/web/scripts/try-quiz-parse.ts` | `cd packages/web && npx --yes tsx scripts/try-quiz-parse.ts` |
| `packages/admin-web/scripts/try-auth-parse.ts` | `cd packages/admin-web && npx --yes tsx scripts/try-auth-parse.ts` |
| `packages/backend/play.go`（`//go:build ignore`） | `cd packages/backend && go run play.go` |

恒久ケースは `tests/` または `*_test.go` へ。`play.local.ts` は gitignore。Vitest は [`../../scripts/fail-on-console.ts`](../../scripts/fail-on-console.ts) を setup し、テスト中の `console.*` を落とす。連続 `//` 散文は [`../../scripts/check-comments.ts`](../../scripts/check-comments.ts)（`npm run check:comments`）。

## ドキュメント例のテスト

`docs/detailed-design/web/` の fenced TypeScript は `packages/web/tests/contract/docs-examples.test.ts` が実装と fixtures で実行する。例を変えたら実装かテストも同じ差分で直す。ページ追加時は [`writing.md`](./writing.md) に従い `python3 scripts/generate_llms_txt.py` を走らせる。

## フック

- pre-commit: `lint-staged`（ESLint / gofmt / 契約チェック）
- pre-push: `npm run test:contract`
- CI `quality.yml`: 毎 PR で衛生、ルート `npm ci` + `npm test`、循環 import（install 後）

Node は `.nvmrc` の 22。ルート `package.json` の workspaces が `packages/web` と `packages/admin-web` を見る。依存関係はルートで `npm i`（lockfile もルートだけ）。Dependabot はルート npm、`packages/backend/`、GitHub Actions を週次で見る。

## TypeScript

ルート [`../../tsconfig.base.json`](../../tsconfig.base.json) は Zod の [`.configs/tsconfig.base.json`](https://github.com/colinhacks/zod/blob/main/.configs/tsconfig.base.json) と同じコンパイラフラグと `"exclude": ["node_modules"]` を置く。`packages/web/` と `packages/admin-web/` はこれを継承し、Vite が必要な `bundler` / `react-jsx` / `noEmit` だけ上書きする。エディタは VS Code 同梱の TypeScript ではなく、ルート `node_modules/typescript` を使う（`.vscode/settings.json` の `js/ts.tsdk.path`）。開いていないファイルの TS エラーも Problems に出す（`js/ts.tsserver.experimental.enableProjectDiagnostics`）。TS / TSX の保存時は ESLint を formatter にし、`source.fixAll.eslint` を走らせる。Biome は使わない（TASK-005）。

## Dev Container

[`.devcontainer/devcontainer.json`](../../.devcontainer/devcontainer.json) は Zod の空テンプレをコピーしない。Node 22・Go・Python・Docker-in-Docker・`npm` を入れる。`postCreateCommand` は `npm i`。[ADR 0011](../adr/0011-devcontainer-runtimes.md)。

## VS Code launch

`.vscode/launch.json` は置かない。Zod の `tsx` + `@zod/source` はコピーしない。試し書きは `npm run play` / `go run`。[ADR 0012](../adr/0012-vscode-launch.json.md)。
