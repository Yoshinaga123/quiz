# ADR 0010: バンドルサイズ実験の入口は手元の `scratch/input.ts`

- Status: Accepted
- Date: 2026-08-14
- Updated: 2026-08-16
- Deciders: Quiz App Team
- Related: ADR 0002（まず bundle size を測る）

## Context

Zod の tree-shake 実験は、本番エントリではなく小さな TypeScript 入口を Rollup し、残った kB を見る。
入口の名前をその都度決めると、エージェントも人も置き場を増やしてしまう。

Zod は `scratch/` 全体を gitignore する。入口ファイルはリポジトリに載せない。計測用 Rollup 設定だけをコミットする。

## Decision

バンドルサイズ（kB）実験の TypeScript 入口は **`scratch/input.ts`** とする。フォルダごと gitignore する（Zod と同じ）。

- パス名は `./scratch/input.ts` で固定する。別名は使わない。
- このファイルは手元で作る。コミットしない。`packages/web/src/` や `packages/admin-web/src/` からは import しない。
- 計測コマンドは `npm run scratch:measure`（`scripts/scratch-measure.mjs`）。出力と `RESULTS.md` も gitignore。
- コミットする道具は `scripts/scratch-measure.mjs`、`scripts/rollup.scratch.config.js`、`scripts/scratch-tsconfig.json`。
- 振る舞いの試し書きは `play.ts` / `packages/web/scripts/` などへ。`scratch/input.ts` には置かない。

## Consequences

### Positive

- 入口の名前は固定したまま、計測用紙をリポジトリに混ぜない。
- Zod の `.gitignore` の `scratch` と同じ扱い。

### Negative / follow-up

- クローンしただけでは `npm run scratch:measure` は失敗する。先に `scratch/input.ts` を手元で作る。
- 過去の kB 表は git の正本に残さない。必要ならその場で測り直す。
