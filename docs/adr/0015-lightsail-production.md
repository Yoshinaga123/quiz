# ADR 0015: 本番は AWS Lightsail 1台

- Status: Accepted
- Date: 2026-08-18
- Deciders: Quiz App Team
- Related: ADR 0005, [`../deploy-lightsail.md`](../deploy-lightsail.md)

## Context

想定利用者は月おおよそ 100 人。同時接続はほぼ 1 桁。公開面は `https://socrates-quiz.jp`。

以前の構成メモは ALB / CloudFront で TLS 終端する前提だった。この人数では過剰で、リポジトリにも IaC が無かった。

## Decision

本番の計算・DB・静的配信は **AWS Lightsail の Linux インスタンス 1台** に置く。

- リージョン: 東京（`ap-northeast-1`）
- 目安プラン: **2 GB RAM**（公開 IPv4 付き、2026-08 時点で約 $12 / 月）
- TLS: インスタンス上の Caddy（Let’s Encrypt）。ALB / CloudFront は使わない
- ユーザー Web: `https://socrates-quiz.jp`
- 管理 Web: `https://admin.socrates-quiz.jp`（同じマシン。ADR 0005 の別ホスト）
- API: 同じオリジンにリバースプロキシ（ユーザーは `/v1`、管理は `/api`）
- PostgreSQL は同じ Compose 内。マネージド DB は後回し

手順と Compose は [`../deploy-lightsail.md`](../deploy-lightsail.md) と `deploy/lightsail/`。

## Consequences

### Positive

- 月額が見積もりやすい
- デプロイ対象が1台
- 月100人に対して十分な余裕

### Negative / follow-up

- ディスク障害とインスタンス障害が単一障害点。Lightsail のスナップショットを取る
- CORS の Origin 反射は残っている。公開後に allowlist 化する（`SECURITY.md`）
- この ADR は置き場の決定。DNS を向けるまで本番公開（WBS 9.3）ではない
