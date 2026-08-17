# ADR 0012: VS Code `launch.json` は Zod のコピーを置かない

- Status: Accepted
- Date: 2026-08-17
- Deciders: Quiz App Team
- Related: ADR 0011（Zod から借りるのは形ではなく線）

## Context

[Zod の `.vscode/launch.json`](https://github.com/colinhacks/zod/blob/main/.vscode/launch.json) は、開いている TypeScript を F5 でデバッグするための2本である。

| 名前 | 内容 |
| --- | --- |
| `node` | `"program": "${file}"`。`--experimental-strip-types` で `.ts` を Node が直接実行する |
| `tsx` | 同じく `${file}`。`tsx` と `--conditions=@zod/source` |

`@zod/source` は Zod 本体の未公開ソースを解決する export condition である。quiz には無い。

quiz は `.vscode/settings.json` と `extensions.json` だけ持つ。`launch.json` は置いていない。試し書きは `npm run play` / `go run play.go` で足りている。

## Decision

Zod の `launch.json` を丸写ししない。`--conditions=@zod/source` は入れない。

借りてよい線（将来 `launch.json` を足すとき）:

- 入口は `${file}`。毎回 `play.ts` に固定しない
- `skipFiles` で `node_internals` と `node_modules` をスタックから外す
- `console` は `integratedTerminal`

足すなら TypeScript の `tsx` 一本より、**Go（Delve）で `packages/backend` を止める** 方がこのリポジトリでは効く。Vite の画面デバッグは `npm run dev` 側であり、Zod の launch ではやらない。

今はファイルを置かない。デバッグは既存の `npm run play` と `go run` で行う。

## Consequences

### Positive

- 使わない export condition や Zod 専用バイナリ経路を設定に混ぜない
- F5 が無いことは、試し書きコマンドが正本であることの印になる

### Negative / follow-up

- エディタの F5 では `play.ts` を止められない。必要になったらこの ADR の線で短い `launch.json` を足す
