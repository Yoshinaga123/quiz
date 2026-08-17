# ADR 0013: 実行速度の比較は `packages/bench`

- Status: Accepted
- Date: 2026-08-17
- Deciders: Quiz App Team
- Related: ADR 0010（kB は手元の `scratch/input.ts`）

## Context

Zod はバンドルサイズを gitignore の `scratch/` で測り、実行速度はコミットする [`packages/bench`](https://github.com/colinhacks/zod/tree/main/packages/bench) で測る。quiz は kB だけ借りていた。

`scratch/` に速度計測を混ぜると、gitignore 下に道具が残る。`play.ts` に混ぜると試し書きと数値が同じファイルになる。

## Decision

実行速度の比較パッケージは **`packages/bench`** に置く（Zod と同じパス）。

- コマンドは `npm run bench`（既定は `quiz-parse`）
- 測る対象はこのアプリの公開 Zod（`packages/web` の `quizSchema`）と `docs/api/fixtures/`
- ArkType / Valibot / Zod 3 は入れない。ライブラリ戦争用の依存を商品リポジトリに増やさない
- npm workspaces には入れない。lockfile はルートだけ。`tinybench` はルートの devDependency
- `npm test` には入れない。数字は CI の合否にしない
- kB は引き続き ADR 0010。こちらは ops/sec

## Consequences

### Positive

- scratch（gitignore）と bench（コミット）の役割が Zod と同じ線になる
- クローンした直後から `npm run bench` が回る

### Negative / follow-up

- 数字はマシン依存。正本には残さない。必要ならその場で測り直す
