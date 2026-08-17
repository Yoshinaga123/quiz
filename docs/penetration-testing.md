# Penetration Testing Guide

このドキュメントは、quiz アプリに OWASP ZAP ベースラインスキャンを導入して、
継続的に Web/API の典型的な脆弱性シグナルを検出するための手順をまとめたもの。

## Scope

- Target: `packages/backend/` が提供する HTTP API
- Default URL: `http://127.0.0.1:8082`
- Scan type: OWASP ZAP Baseline Scan (DAST)

## Local Run

前提:

- Docker が利用可能
- `packages/backend/` の依存コンテナが起動できる

実行:

```bash
bash scripts/run_zap_baseline.sh
```

オプション:

```bash
TARGET_URL=http://127.0.0.1:8082 \
ZAP_SPIDER_MINUTES=3 \
bash scripts/run_zap_baseline.sh
```

出力先:

- `reports/security/zap/zap-report.html`
- `reports/security/zap/zap-report.md`
- `reports/security/zap/zap-report.xml`

## CI Integration

GitHub Actions に `security-pentest.yml` を追加済み。

- Trigger:
  - `workflow_dispatch`
  - `pull_request` (`packages/backend/` / `packages/web/` / `packages/admin-web/` / security workflow 変更時)
- 実行内容:
  1. `packages/backend/docker compose` で API を起動
  2. `/healthz` が起動するまで待機
  3. ZAP ベースラインスキャンを実行
  4. レポートを Artifact として保存

## Rules of Engagement

- 許可された対象に対してのみ実行する
- 本番環境への直接実行は避け、ステージングまたはローカルで先に検証する
- 高負荷スキャン（アクティブスキャン）を有効にする場合は運用合意を取る

## Limitations

- ベースラインスキャンは受動検査中心のため、網羅的な侵入テストではない
- 認証必須の管理 API は現状スコープ外
- SQLi/XSS などの深い検証は、別途アクティブスキャン計画で補完する
