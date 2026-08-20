# ADR 0015: 本番は AWS Lightsail 1台

- Status: Accepted
- Date: 2026-08-18
- Deciders: Quiz App Team
- Related: ADR 0001, ADR 0006, ADR 0008

## Context

公開ホストは `https://socrates-quiz.jp`（HTTPS 443）と決めている。
当面のトラフィックは小さく、ALB + ECS + RDS の分割は運用コストが勝る。

## Decision

本番は **AWS Lightsail 1 インスタンス** に Docker Compose で載せる。

| 層 | 役割 |
| --- | --- |
| Caddy | TLS 終端（Let's Encrypt）、リバースプロキシ |
| `packages/web` | SPA（nginx） |
| `packages/backend` | Go API（コンテナ内 8080） |
| PostgreSQL 16 | 同一 Compose の永続ボリューム |

公開ポートは **80 / 443 のみ**。API の 8080 はホストへ晒さない。
ユーザー Web と公開 API は **同一オリジン** で配信する。

ドメイン取得前も **静的 IP + HTTPS** で公開する（[`docs/deploy-lightsail.md`](../deploy-lightsail.md)）。
Caddy は Let's Encrypt の短期 IP アドレス証明書を取得し、永続化したデータ領域を使って自動更新する。
HTTP は HTTPS へリダイレクトし、管理 API（`/api`）はエッジから出さない。
ドメインは必要になった時点で同じ静的 IP に追加できる。

## Consequences

### Positive

- TLS・DNS・アプリを 1 台で完結できる
- 既存の Dockerfile（web runtime / backend runtime）をそのまま使える
- マイグレーションは API 起動時の `go:embed` で適用される
- `develop` への該当パス push で self-hosted runner 経由の CD が可能（[`docs/deploy-lightsail.md`](../deploy-lightsail.md)）

### Negative

- 単一障害点（インスタンス障害 = 全体停止）
- DB も同ホストなのでバックアップとスナップショットが必須
- IP アドレス証明書は有効期間が短く、Caddy の継続稼働と自動更新監視が必要
- CD 用 self-hosted runner が同ホスト上にいる（ホスト侵害時の影響範囲に注意）
- スケールアウトは別 ADR が必要

## Alternatives Considered

- **ALB + ECS + RDS**: 正しいがオーバースペック。トラフィックが増えてから再検討する。
- **Cloudflare Tunnel のみ**: Lightsail 静的 IP + 正規 DNS の方が運用が単純。
