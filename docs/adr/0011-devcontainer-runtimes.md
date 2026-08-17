# ADR 0011: Dev Container にはこのリポジトリが実際に使うランタイムだけ入れる

- Status: Accepted
- Date: 2026-08-16
- Updated: 2026-08-16
- Deciders: Quiz App Team
- Related: ADR 0010（Zod から借りるのは形ではなく線）

## Context

[Zod の `.devcontainer/devcontainer.json`](https://github.com/colinhacks/zod/blob/main/.devcontainer/devcontainer.json) は、公式テンプレート `typescript-node` をほぼそのまま置き、有効な行は次の3つだけである。

- `name`
- `image`（Node 20 + TypeScript）
- `postCreateCommand`: `pnpm i`

`features` / `forwardPorts` / `customizations` / `remoteUser` はコメントのまま。Go も Python も Docker-in-Docker もない。Zod は TypeScript ライブラリなので、その箱で必要なのは Node と `pnpm i` だけだからである。

quiz はアプリケーションモノレポである。同じ薄さにすると、この箱では `go test` も契約チェックも compose も動かない。

## Decision

Zod から借りるのは「テンプレを空にする」ことではない。**このリポジトリが本当に使うランタイム以外を入れない** という線である。

[`.devcontainer/devcontainer.json`](../../.devcontainer/devcontainer.json) の正本は次のとおり。Zod の空 `features` に合わせない。

| 項目 | 値 | 理由 |
| --- | --- | --- |
| `image` | `javascript-node:22` | `.nvmrc` の Node 22 |
| `features.go` | 1.26 | `packages/backend` |
| `features.python` | 3.12 | `scripts/check_public_contract.py` など |
| `features.docker-in-docker` | 既定 | compose / 証明書まわり |
| `postCreateCommand` | `npm i` | ルートの npm workspaces が `packages/web` と `packages/admin-web` を入れる。pnpm にはしない |
| `customizations.vscode.extensions` | ESLint / Go / YAML | その3言語を触るため |

足さないもの:

- Zod に合わせて `features` を空にすること
- 使っていないランタイムや拡張を「将来用」に先置きすること
- Flutter SDK（モバイル作業はホスト側。コンテナを Flutter 作業場にする決定は別 ADR）

## Consequences

### Positive

- コンテナを開けば、このリポジトリの Node / Go / Python / Docker 作業が同じ箱でできる。
- Zod を真似して features を消す、という誤った「軽量化」を防げる。

### Negative / follow-up

- Zod の箱よりイメージは重い。quiz が Go・Python・DinD を使う以上、それは意図したコストである。
- `packages/mobile/` の Flutter はこのコンテナでは揃わない。
