# ADR 0010: バンドルサイズ実験の入口は `scratch/input.ts`

- Status: Accepted
- Date: 2026-08-14
- Deciders: Quiz App Team
- Related: ADR 0002（まず bundle size を測る）

## Context

Zod の tree-shake 実験は、本番エントリではなく小さな TypeScript 入口を Rollup し、残った kB を見る。
入口の名前をその都度決めると、エージェントも人も置き場を増やしてしまう。

このリポジトリにはすでに振る舞いの試し書き（`play.ts`、`web/scripts/` など）がある。
**コードサイズ（kB）がどう変化するか** を見る実験は、それとは別物である。

## Decision

バンドルサイズ（kB）実験の TypeScript 入口は、リポジトリルートの **`scratch/input.ts`** とする。

- パスは `./scratch/input.ts` で固定する。別名（`in.ts`、`bundle-entry.ts`、`web/scratch/` など）は使わない。
- このファイルは計測用であり、`web/src/` や `admin-web/src/` からは import しない。Vite の本番エントリにもしない。
- スキーマや fetch の振る舞いを試すときは、これまでどおり `play.ts` / `web/scripts/` / `admin-web/scripts/` / `backend/play.go` を使う。`scratch/input.ts` には置かない。

計測コマンドは `npm run scratch:measure`。出力は `scratch/out_rollup.js`（named import）と、比較用の一時出力 `scratch/out_rollup_namespace.js`。どちらも gitignore。差分の正本は `scratch/RESULTS.md`。

## Consequences

### Positive

- 「サイズ実験の入口はどこか」を毎回判断しなくてよい。
- Zod の `scratch/input.ts` と同じ名前なので、参照元の設定を読み替えやすい。

### Negative / follow-up

- `play.ts` と `scratch/input.ts` の二系統になる。用途が違うので許容する。
- 出力は `scratch/out_rollup.js` / `scratch/out_rollup_namespace.js`（gitignore）。再実行は `npm run scratch:measure`。
