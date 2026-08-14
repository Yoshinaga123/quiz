# Documentation Index

クイズアプリのドキュメント一覧。リポジトリ全体の航海図として使う。  
プロダクトの入口はルートの [`../README.md`](../README.md)。学習用の隔離方針は [`../archive/README.md`](../archive/README.md)。

## アーキテクチャ

| ドキュメント | 概要 |
| --- | --- |
| [`./architecture/overview.md`](./architecture/overview.md) | システム構成概要（コンポーネント図・API 一覧・Seed 同期フロー） |
| [`./architecture/backend-flow.md`](./architecture/backend-flow.md) | Go API の入口処理、公開 API、管理ログイン、認証付き CRUD の流れ |
| [`./architecture/data-model.md`](./architecture/data-model.md) | 永続テーブル、seed JSON、公開 API への投影モデルの関係 |

## 詳細設計

内部の組み立て（ハンドラ、SQL、画面内状態）。基本設計（`architecture/` / `api/` / `adr/`）とは別フォルダ。目次は [`./detailed-design/meta.json`](./detailed-design/meta.json)。

| ドキュメント | 概要 |
| --- | --- |
| [`./detailed-design/README.md`](./detailed-design/README.md) | 置き場・書き方・他ドキュメントとの境界 |
| [`./detailed-design/backend/`](./detailed-design/backend/) | Go API・DB アクセス |
| [`./detailed-design/backend/package-layout.md`](./detailed-design/backend/package-layout.md) | `package main` のファイル分割 |
| [`./detailed-design/web/`](./detailed-design/web/) | ユーザー向け Web |
| [`./detailed-design/web/quiz-schema.md`](./detailed-design/web/quiz-schema.md) | 公開クイズ Zod（`.refine` 含む） |
| [`./detailed-design/web/public-contract.md`](./detailed-design/web/public-contract.md) | 公開契約の同一 PR 同期 |
| [`./detailed-design/admin-web/`](./detailed-design/admin-web/) | 管理画面 |
| [`./detailed-design/mobile/`](./detailed-design/mobile/) | Flutter |

## プロジェクト全体

| ドキュメント | 概要 |
| --- | --- |
| [`../quiz.md`](../quiz.md) | アプリの要件定義（実装準拠のスタック） |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | 貢献手順（OpenAPI / Zod / テスト同期） |
| [`../SECURITY.md`](../SECURITY.md) | 脆弱性報告 |
| [`./implement-policy.md`](./implement-policy.md) | 実装ポリシー（Zod 検証、SPA 採用、Google Search Central 対応など） |
| [`./validation-policy.md`](./validation-policy.md) | フロント／バックの入力検証ポリシー |
| [`./quiz-data-workflow.md`](./quiz-data-workflow.md) | クイズデータの 3 層フロー（候補プール → 本番シード → DB） |
| [`./firebase-api-key-handling.md`](./firebase-api-key-handling.md) | Firebase API キーと `GoogleService-Info.plist` の扱い方針 |
| [`./local-https-setup.md`](./local-https-setup.md) | ローカル開発環境の HTTPS 設定（自己署名証明書 + Vite） |
| [`./counter-api.md`](./counter-api.md) | PV カウンター API（`/counter`、永続化は `views` テーブル） |
| [`./push-notification-mock.md`](./push-notification-mock.md) | Push 通知 Phase A モック（手動送信 + feed + ローカル通知） |
| [`./quizzes-quality-review.md`](./quizzes-quality-review.md) | `quizzes.json` 全体の品質レビューと修正優先順 |
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
| [`./api/fixtures/`](./api/fixtures/README.md) | 公開契約の実行時 example（Zod / Go と共有） |

## サブプロジェクト別 README

| パス | 内容 |
| --- | --- |
| [`../admin-web/README.md`](../admin-web/README.md) | 管理画面（React + Vite） |
| [`../admin-web/tests/README.md`](../admin-web/tests/README.md) | `admin-web/` の Vitest（Zod スキーマ含む） |
| [`../admin-web/docs/linting.md`](../admin-web/docs/linting.md) | 管理画面の Lint ルール |
| [`../web/README.md`](../web/README.md) | ユーザー向け Web アプリ（React + Vite） |
| [`../web/tests/README.md`](../web/tests/README.md) | `web/` の Vitest（Zod スキーマ含む） |
| [`../web/scripts/README.md`](../web/scripts/README.md) | Zod `play.ts` 相当の試し書き |
| [`../mobile/README.md`](../mobile/README.md) | モバイル版（Flutter + Riverpod） |
| [`../backend/README.md`](../backend/README.md) | Go API（Public / Admin / 認証 / Seed 同期） |

## CI / 運用スクリプト

| パス | 役割 |
| --- | --- |
| [`../.github/workflows/frontend.yml`](../.github/workflows/frontend.yml) | `admin-web/` と `web/` のビルド・Lint・Test |
| [`../.github/workflows/backend.yml`](../.github/workflows/backend.yml) | Go の vet / build / test |
| [`../.github/workflows/quiz-data.yml`](../.github/workflows/quiz-data.yml) | クイズ JSON の lint と本番シード drift 検出 |
| [`../.github/workflows/openapi.yml`](../.github/workflows/openapi.yml) | OpenAPI 仕様の Redocly Lint |
| [`../.github/workflows/public-contract.yml`](../.github/workflows/public-contract.yml) | 公開契約（OpenAPI + fixtures + Zod + Go） |
| [`../scripts/check_public_contract.py`](../scripts/check_public_contract.py) | OpenAPI / fixtures / Zod / Go のフィールド同期 |
| [`../.github/workflows/security-pentest.yml`](../.github/workflows/security-pentest.yml) | OWASP ZAP ベースライン・ペネトレーションテスト |
| [`../scripts/lint_quizzes.py`](../scripts/lint_quizzes.py) | クイズ JSON の構造 lint |
| [`../scripts/diff_quiz_data.py`](../scripts/diff_quiz_data.py) | 候補プールと本番シードの差分要約 |
| [`../scripts/check_quiz_drift.py`](../scripts/check_quiz_drift.py) | 本番シードと最新マイグレーションの drift 検出 |
| [`../scripts/generate_migration.py`](../scripts/generate_migration.py) | シード JSON から SQL を生成 |
| [`../scripts/create_seed_migration.py`](../scripts/create_seed_migration.py) | `golang-migrate create` ラッパ |
| [`../scripts/create_backend_env.py`](../scripts/create_backend_env.py) | `backend/.env` のセットアップ補助 |
| [`../scripts/run_zap_baseline.sh`](../scripts/run_zap_baseline.sh) | ローカル向け OWASP ZAP ベースライン実行 |

## 学習・診断アーカイブ（プロダクトではない）

| パス | 概要 |
| --- | --- |
| [`../archive/README.md`](../archive/README.md) | 隔離方針 |
| [`../samples/README.md`](../samples/README.md) | 参考クローン |
| [`./security-tools/`](./security-tools/owasp-zap.md) | ZAP / Burp / w3af 手順 |
| [`./penetration-testing.md`](./penetration-testing.md) | ペネトレーション導入 |
| [`./script-learning-tasks.md`](./script-learning-tasks.md) | 学習用スクリプト課題 |
| [`./Matt_Pocock_says/`](./Matt_Pocock_says/the-magic-of-typescript.md) | TypeScript 学習メモ |
