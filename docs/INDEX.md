# Documentation Index

クイズアプリのドキュメント一覧。リポジトリ全体の航海図として使う。

## アーキテクチャ

| ドキュメント | 概要 |
| --- | --- |
| [`./architecture/overview.md`](./architecture/overview.md) | システム構成概要（コンポーネント図・API 一覧・Seed 同期フロー） |
| [`./architecture/backend-flow.md`](./architecture/backend-flow.md) | Go API の入口処理、公開 API、管理ログイン、認証付き CRUD の流れ |
| [`./architecture/data-model.md`](./architecture/data-model.md) | 永続テーブル、seed JSON、公開 API への投影モデルの関係 |

## プロジェクト全体

| ドキュメント | 概要 |
| --- | --- |
| [`../quiz.md`](../quiz.md) | アプリの要件定義（Mobile / Web / Admin / Backend の構成と原則） |
| [`./implement-policy.md`](./implement-policy.md) | 実装ポリシー（Zod 検証、SPA 採用、Google Search Central 対応など） |
| [`./validation-policy.md`](./validation-policy.md) | フロント／バックの入力検証ポリシー |
| [`./quiz-data-workflow.md`](./quiz-data-workflow.md) | クイズデータの 3 層フロー（候補プール → 本番シード → DB） |
| [`./firebase-api-key-handling.md`](./firebase-api-key-handling.md) | Firebase API キーと `GoogleService-Info.plist` の扱い方針 |
| [`./local-https-setup.md`](./local-https-setup.md) | ローカル開発環境の HTTPS 設定（自己署名証明書 + Vite） |
| [`./counter-api.md`](./counter-api.md) | PV カウンター API（`/counter`、永続化は `views` テーブル） |
| [`./push-notification-mock.md`](./push-notification-mock.md) | Push 通知 Phase A モック（手動送信 + feed + ローカル通知） |
| [`./penetration-testing.md`](./penetration-testing.md) | OWASP ZAP によるベースライン・ペネトレーションテスト導入手順 |
| [`./quizzes-quality-review.md`](./quizzes-quality-review.md) | `quizzes.json` 全体の品質レビューと修正優先順 |
| [`./script-learning-tasks.md`](./script-learning-tasks.md) | 追加すると便利な開発スクリプトの学習課題 |
| [`./backlog.md`](./backlog.md) | 未着手の改善タスク（出典品質・テスト基盤など） |
| [`./initializer.md`](./initializer.md) | 初期化責務の所在 |
| [`./late.md`](./late.md) | 遅延読み込みの方針 |
| [`../backend/.env.example`](../backend/.env.example) | backend 環境変数テンプレート |
| [`../web/.env.example`](../web/.env.example) | web 環境変数テンプレート |

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
| [`../backend/README.md`](../backend/README.md) | Go API（Public / Admin / 認証 / Seed 同期） |

## CI / 運用スクリプト

| パス | 役割 |
| --- | --- |
| [`../.github/workflows/frontend.yml`](../.github/workflows/frontend.yml) | `admin-web/` と `web/` のビルド・Lint |
| [`../.github/workflows/backend.yml`](../.github/workflows/backend.yml) | Go の vet / build / test |
| [`../.github/workflows/quiz-data.yml`](../.github/workflows/quiz-data.yml) | クイズ JSON の lint と本番シード drift 検出 |
| [`../.github/workflows/openapi.yml`](../.github/workflows/openapi.yml) | OpenAPI 仕様の Redocly Lint |
| [`../.github/workflows/security-pentest.yml`](../.github/workflows/security-pentest.yml) | OWASP ZAP ベースライン・ペネトレーションテスト |
| [`../scripts/lint_quizzes.py`](../scripts/lint_quizzes.py) | クイズ JSON の構造 lint |
| [`../scripts/diff_quiz_data.py`](../scripts/diff_quiz_data.py) | 候補プールと本番シードの差分要約 |
| [`../scripts/check_quiz_drift.py`](../scripts/check_quiz_drift.py) | 本番シードと最新マイグレーションの drift 検出 |
| [`../scripts/generate_migration.py`](../scripts/generate_migration.py) | シード JSON から SQL を生成 |
| [`../scripts/create_seed_migration.py`](../scripts/create_seed_migration.py) | `golang-migrate create` ラッパ |
| [`../scripts/create_backend_env.py`](../scripts/create_backend_env.py) | `backend/.env` のセットアップ補助 |
| [`../scripts/run_zap_baseline.sh`](../scripts/run_zap_baseline.sh) | ローカル向け OWASP ZAP ベースライン実行 |
