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
| [`./detailed-design/writing.md`](./detailed-design/writing.md) | frontmatter / 例のテスト / llms.txt |
| [`./detailed-design/backend/`](./detailed-design/backend/) | Go API・DB アクセス |
| [`./detailed-design/backend/package-layout.md`](./detailed-design/backend/package-layout.md) | `package main` のファイル分割 |
| [`./detailed-design/web/`](./detailed-design/web/) | ユーザー向け Web |
| [`./detailed-design/web/basics.md`](./detailed-design/web/basics.md) | Zod Basics 相当（safeParse / infer） |
| [`./detailed-design/web/quiz-schema.md`](./detailed-design/web/quiz-schema.md) | 公開クイズ Zod（`.refine` 含む） |
| [`./detailed-design/web/error-formatting.md`](./detailed-design/web/error-formatting.md) | Zod issues → ApiError |
| [`./detailed-design/web/public-contract.md`](./detailed-design/web/public-contract.md) | 公開契約の同一 PR 同期 |
| [`./detailed-design/repo-ops.md`](./detailed-design/repo-ops.md) | husky / play / Dev Container / docs 例テスト |
| [`./detailed-design/admin-web/`](./detailed-design/admin-web/) | 管理画面 |
| [`./detailed-design/admin-web/quiz-schema.md`](./detailed-design/admin-web/quiz-schema.md) | 管理画面 Zod（公開 schema との差） |
| [`./detailed-design/mobile/`](./detailed-design/mobile/) | Flutter |
| [`./detailed-design/mobile/remote-data-source.md`](./detailed-design/mobile/remote-data-source.md) | 公開 API の remote 経路 |

## プロジェクト全体

| ドキュメント | 概要 |
| --- | --- |
| [`../quiz.md`](../quiz.md) | アプリの要件定義（実装準拠のスタック） |
| [`./quiz-app-wbs.md`](./quiz-app-wbs.md) | 1人開発の概算 WBS（仮置き日程） |
| [`../AGENTS.md`](../AGENTS.md) | コーディングエージェント向け手順 |
| [`../CLAUDE.md`](../CLAUDE.md) | AGENTS.md への入口 |
| [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Contributor Covenant |
| [`./llms.txt`](./llms.txt) | 詳細設計の目録（zod.dev/llms.txt 相当） |
| [`./llms-full.txt`](./llms-full.txt) | 詳細設計の連結（zod.dev/llms-full.txt 相当） |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | 貢献手順（OpenAPI / Zod / テスト同期） |
| [`../SECURITY.md`](../SECURITY.md) | 脆弱性報告 |
| [`./implement-policy.md`](./implement-policy.md) | 実装ポリシー（Zod 検証、SPA 採用、Google Search Central 対応など） |
| [`./validation-policy.md`](./validation-policy.md) | フロント／バックの入力検証ポリシー |
| [`./quiz-data-workflow.md`](./quiz-data-workflow.md) | クイズデータの 3 層フロー（候補プール → 本番シード → DB） |
| [`./firebase-api-key-handling.md`](./firebase-api-key-handling.md) | Firebase 設定は gitignore。このアプリのプロジェクト以外を入れない |
| [`./local-https-setup.md`](./local-https-setup.md) | ローカル開発環境の HTTPS 設定（自己署名証明書 + Vite） |
| [`./deploy-lightsail.md`](./deploy-lightsail.md) | 本番 Lightsail 1台の起動手順 + CD（ADR 0015） |
| [`.github/workflows/auto-pr-merge.yml`](../.github/workflows/auto-pr-merge.yml) | feature ブランチ push で PR 作成 + CI 緑で auto-merge |
| [`./counter-api.md`](./counter-api.md) | PV カウンター API（`/counter`、永続化は `views` テーブル） |
| [`./push-notification-mock.md`](./push-notification-mock.md) | Push 通知 Phase A モック（手動送信 + feed + ローカル通知） |
| [`./quizzes-quality-review.md`](./quizzes-quality-review.md) | `quizzes.json` 全体の品質レビューと修正優先順 |
| [`./backlog.md`](./backlog.md) | 未着手の改善タスク（出典品質・テスト基盤・Zod Mini / Biome 先送りなど） |
| [`./initializer.md`](./initializer.md) | 初期化責務の所在 |
| [`./late.md`](./late.md) | 遅延読み込みの方針 |
| [`../packages/backend/.env.example`](../packages/backend/.env.example) | backend 環境変数テンプレート |
| [`../packages/web/.env.example`](../packages/web/.env.example) | web 環境変数テンプレート |

## アーキテクチャ決定記録（ADR）

ADR は、複数領域に長期間影響し、後戻りコストが高い判断に限定する。認証境界、公開契約、データの正本、本番構成、アプリ分離などが対象となる。実験方法、コマンド、エディタ設定、局所的なツール構成、通常の依存関係更新は GitHub Issue / PR に残す（整理経緯: [Issue #19](https://github.com/Yoshinaga123/quiz/issues/19)）。

| 番号 | 状態 | タイトル |
| --- | --- | --- |
| [0001](./adr/0001-counter-api-architecture.md) | Accepted | カウンタ API 構成 |
| [0002](./adr/0002-frontend-architecture-spa.md) | Accepted | フロントエンドを Vite + React SPA で構築 |
| [0003](./adr/0003-styling-tailwindcss.md) | Accepted | スタイリングに Tailwind CSS を採用 |
| [0004](./adr/0004-login-verification-code-flow.md) | Accepted | ログインの検証コードフロー |
| [0005](./adr/0005-user-facing-web-quiz-app.md) | Accepted | ユーザー向け Web クイズアプリ (`packages/web/`) |
| [0006](./adr/0006-public-quiz-api.md) | Accepted | 公開クイズ API の仕様分離 |
| [0007](./adr/0007-push-notification-delivery.md) | Proposed | プッシュ通知の配信方式 |
| [0008](./adr/0008-user-attempt-history.md) | Accepted | ユーザー回答履歴の保存方式 |
| [0009](./adr/0009-mobile-state-management.md) | Accepted | モバイル版の状態管理と層構造 |
| [0015](./adr/0015-lightsail-production.md) | Accepted | 本番は AWS Lightsail 1台 |

## API 仕様

| ファイル | 概要 |
| --- | --- |
| [`./api/public-quiz-api.yaml`](./api/public-quiz-api.yaml) | 公開クイズ API（OpenAPI 3.1 ドラフト、ADR 0006） |
| [`./api/fixtures/`](./api/fixtures/README.md) | 公開契約の実行時 example（Zod / Go と共有） |

## サブプロジェクト別 README

| パス | 内容 |
| --- | --- |
| [`../packages/admin-web/README.md`](../packages/admin-web/README.md) | 管理画面（React + Vite） |
| [`../packages/admin-web/tests/README.md`](../packages/admin-web/tests/README.md) | `packages/admin-web/` の Vitest（Zod スキーマ含む） |
| [`./linting.md`](./linting.md) | フロントエンドの Lint / tsconfig 方針 |
| [`../packages/web/README.md`](../packages/web/README.md) | ユーザー向け Web アプリ（React + Vite） |
| [`../packages/web/tests/README.md`](../packages/web/tests/README.md) | `packages/web/` の Vitest（Zod スキーマ含む） |
| [`../packages/web/scripts/README.md`](../packages/web/scripts/README.md) | Zod `play.ts` 相当の試し書き |
| [`../packages/admin-web/scripts/README.md`](../packages/admin-web/scripts/README.md) | 管理画面スキーマの試し書き |
| [`../play.ts`](../play.ts) | ルートの試し書き（`npm run play`） |
| [`../scripts/scratch-measure.mjs`](../scripts/scratch-measure.mjs) | バンドルサイズ計測（手元の `scratch/input.ts`。フォルダは gitignore） |
| [`../packages/bench/README.md`](../packages/bench/README.md) | 実行速度計測（ops/sec） |
| [`../packages/mobile/README.md`](../packages/mobile/README.md) | モバイル版（Flutter + Riverpod） |
| [`../packages/backend/README.md`](../packages/backend/README.md) | Go API（Public / Admin / 認証 / Seed 同期） |

## CI / 運用スクリプト

| パス | 役割 |
| --- | --- |
| [`../.github/workflows/frontend.yml`](../.github/workflows/frontend.yml) | `packages/admin-web/` と `packages/web/` のビルド・Lint・Test（`main` / `develop`） |
| [`../.github/workflows/backend.yml`](../.github/workflows/backend.yml) | Go の vet / build / test（`main` / `develop`） |
| [`../.github/workflows/mobile.yml`](../.github/workflows/mobile.yml) | `packages/mobile/` の `flutter analyze` / `flutter test` |
| [`../.github/workflows/quiz-data.yml`](../.github/workflows/quiz-data.yml) | クイズ JSON の lint と本番シード drift 検出 |
| [`../.github/workflows/openapi.yml`](../.github/workflows/openapi.yml) | OpenAPI 仕様の Redocly Lint |
| [`../.github/workflows/public-contract.yml`](../.github/workflows/public-contract.yml) | 公開契約（OpenAPI + fixtures + Zod + Go） |
| [`../.github/workflows/quality.yml`](../.github/workflows/quality.yml) | 衛生 + ルート `npm test` + 循環 import（毎 PR） |
| [`../scripts/check_public_contract.py`](../scripts/check_public_contract.py) | OpenAPI / fixtures / Zod / Go のフィールド同期 |
| [`../scripts/check_repo_hygiene.py`](../scripts/check_repo_hygiene.py) | AGENTS / nvmrc / detailed-design 目次 |
| [`../scripts/check_docs.py`](../scripts/check_docs.py) | frontmatter・孤児ページ・相対リンク・llms drift |
| [`../scripts/generate_llms_txt.py`](../scripts/generate_llms_txt.py) | `docs/llms.txt` と `docs/llms-full.txt` を生成 |
| [`../.github/workflows/security-pentest.yml`](../.github/workflows/security-pentest.yml) | OWASP ZAP ベースライン・ペネトレーションテスト |
| [`../scripts/lint_quizzes.py`](../scripts/lint_quizzes.py) | クイズ JSON の構造 lint |
| [`../scripts/diff_quiz_data.py`](../scripts/diff_quiz_data.py) | 候補プールと本番シードの差分要約 |
| [`../scripts/check_quiz_drift.py`](../scripts/check_quiz_drift.py) | 本番シードと最新マイグレーションの drift 検出 |
| [`../scripts/generate_migration.py`](../scripts/generate_migration.py) | シード JSON から SQL を生成 |
| [`../scripts/create_seed_migration.py`](../scripts/create_seed_migration.py) | `golang-migrate create` ラッパ |
| [`../scripts/create_backend_env.py`](../scripts/create_backend_env.py) | `packages/backend/.env` のセットアップ補助 |
| [`../scripts/run_zap_baseline.sh`](../scripts/run_zap_baseline.sh) | ローカル向け OWASP ZAP ベースライン実行 |

## 学習・診断アーカイブ（プロダクトではない）

| パス | 概要 |
| --- | --- |
| [`../archive/README.md`](../archive/README.md) | 隔離方針（`samples/` などは手元のみ） |
| [`./security-tools/`](./security-tools/owasp-zap.md) | ZAP / Burp / w3af 手順 |
| [`./penetration-testing.md`](./penetration-testing.md) | ペネトレーション導入 |
| [`./script-learning-tasks.md`](./script-learning-tasks.md) | 学習用スクリプト課題 |
| [`./Matt_Pocock_says/`](./Matt_Pocock_says/the-magic-of-typescript.md) | TypeScript 学習メモ |
