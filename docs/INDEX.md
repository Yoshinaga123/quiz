# Documentation Index

クイズアプリのドキュメント一覧。リポジトリ全体の航海図として使う。

## プロジェクト全体

| ドキュメント | 概要 |
| --- | --- |
| [`../quiz.md`](../quiz.md) | アプリの要件定義（Mobile / Web / Admin / Backend の構成と原則） |
| [`./implement-policy.md`](./implement-policy.md) | 実装ポリシー（Zod 検証、SPA 採用、Google Search Central 対応など） |
| [`./validation-policy.md`](./validation-policy.md) | フロント／バックの入力検証ポリシー |
| [`./quiz-data-workflow.md`](./quiz-data-workflow.md) | クイズデータの 3 層フロー（候補プール → 本番シード → DB） |
| [`./initializer.md`](./initializer.md) | 初期化責務の所在 |
| [`./late.md`](./late.md) | 遅延読み込みの方針 |

## アーキテクチャ決定記録（ADR）

| 番号 | 状態 | タイトル |
| --- | --- | --- |
| [0001](./adr/0001-counter-api-architecture.md) | Accepted | カウンタ API 構成 |
| [0002](./adr/0002-frontend-architecture-spa.md) | Accepted | フロントエンドを Vite + React SPA で構築 |
| [0003](./adr/0003-styling-tailwindcss.md) | Accepted | スタイリングに Tailwind CSS を採用 |
| [0004](./adr/0004-login-verification-code-flow.md) | Accepted | ログインの検証コードフロー |
| [0005](./adr/0005-user-facing-web-quiz-app.md) | Accepted | ユーザー向け Web クイズアプリ (`web/`) |
| [0006](./adr/0006-public-quiz-api.md) | Accepted | 公開クイズ API の仕様分離 |
| [0007](./adr/0007-push-notification-delivery.md) | Proposed | プッシュ通知の配信方式 |
| [0008](./adr/0008-user-attempt-history.md) | Proposed | ユーザー回答履歴の保存方式 |
| [0009](./adr/0009-mobile-state-management.md) | Accepted | モバイル版の状態管理と層構造 |

## API 仕様

| ファイル | 概要 |
| --- | --- |
| [`./api/public-quiz-api.yaml`](./api/public-quiz-api.yaml) | 公開クイズ API（OpenAPI 3.1 ドラフト、ADR 0006） |

## サブプロジェクト別 README

| パス | 内容 |
| --- | --- |
| [`../admin-web/README.md`](../admin-web/README.md) | 管理画面（React + Vite） |
| [`../admin-web/docs/linting.md`](../admin-web/docs/linting.md) | 管理画面の Lint ルール |
| [`../web/README.md`](../web/README.md) | ユーザー向け Web アプリ（React + Vite） |
| [`../web/tests/README.md`](../web/tests/README.md) | `web/` のテスト雛形と有効化手順 |
| [`../mobile/README.md`](../mobile/README.md) | モバイル版（Flutter + Riverpod） |
| [`../backend/`](../backend/) | Go API（README は未整備、`main.go` 参照） |

## CI / 運用スクリプト

| パス | 役割 |
| --- | --- |
| [`../.github/workflows/frontend.yml`](../.github/workflows/frontend.yml) | `admin-web/` と `web/` のビルド・Lint |
| [`../.github/workflows/backend.yml`](../.github/workflows/backend.yml) | Go の vet / build / test |
| [`../.github/workflows/quiz-data.yml`](../.github/workflows/quiz-data.yml) | クイズ JSON の lint と本番シード drift 検出 |
| [`../.github/workflows/openapi.yml`](../.github/workflows/openapi.yml) | OpenAPI 仕様の Redocly Lint |
| [`../scripts/lint_quizzes.py`](../scripts/lint_quizzes.py) | クイズ JSON の構造 lint |
| [`../scripts/diff_quiz_data.py`](../scripts/diff_quiz_data.py) | 候補プールと本番シードの差分要約 |
| [`../scripts/check_quiz_drift.py`](../scripts/check_quiz_drift.py) | 本番シードと最新マイグレーションの drift 検出 |
| [`../scripts/generate_migration.py`](../scripts/generate_migration.py) | シード JSON から SQL を生成 |
| [`../scripts/create_seed_migration.py`](../scripts/create_seed_migration.py) | `golang-migrate create` ラッパ |
| [`../scripts/create_backend_env.py`](../scripts/create_backend_env.py) | `backend/.env` のセットアップ補助 |
