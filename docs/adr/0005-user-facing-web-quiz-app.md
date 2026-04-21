# ADR 0005: User-Facing Web Quiz App (`web/`)

- Status: Accepted
- Date: 2026-04-21
- Deciders: Quiz App Team

## Context

`quiz.md` の要件定義では、ユーザー向けクイズアプリを **モバイル版 (Flutter) と Web 版 (React/Vite) の 2 系統** で提供することが定められている。
これまでリポジトリには以下が存在した。

- `admin-web/`: 管理画面（CRUD）
- `mobile/`: モバイル向けクイズアプリ（Flutter, 雛形のみ）
- `backend/`: Go API

一方で **ユーザー向け Web クイズアプリは未着手** だった。
ADR 0002 が SPA 採用を既に決定しているため、本 ADR ではその枠内で「どこに、どのような責務分担で」配置するかを決定する。

## Decision

ユーザー向け Web クイズアプリを `web/` に新規追加する。
管理画面 `admin-web/` とは **物理的に別プロジェクト** として運用し、依存とビルドを完全に分離する。

採用スタックは ADR 0002 / ADR 0003 に揃え、`admin-web/` の規約をそのまま継承する。

- React 19 + TypeScript 5.9
- Vite 7
- Tailwind CSS v4
- React Router v7（History API）
- zod ^4（外部入力・永続化データの境界検証）

履歴データは初期段階では `localStorage` に保存し、サーバー側のユーザーモデルが固まった段階で API へ移行する。

## Rationale

### 1. 責務の物理分離

- 管理画面とユーザー画面は **目的・配信ドメイン・認証境界がすべて異なる**。
- 同一バンドルに同居させると、エンドユーザーに管理 UI のコードが配信される事故、認証ガードの誤適用、依存関係の肥大化が起きやすい。
- フロントエンドの bundle が分割されることで、片方の改修が他方の bundle サイズや CWV に影響しない。

### 2. ADR 0002（SPA）と整合

- 採点・回答フィードバックは「インタラクション駆動」の典型であり、SPA 採用の前提と一致する。
- RSC や Astro Islands に踏み込む必要はない。

### 3. バックエンド未拡張のまま単独で動く構成

- 現時点で `backend/main.go` は公開クイズ取得 API（認証不要の `GET /api/quizzes` 等）を持たない。
- `web/` を **インラインの starter pack（`src/data/quizzes.ts`）** で立ち上げ、後から `loadQuizzes()` の中身だけを fetch + zod 検証へ差し替えられる構造にした。
- これにより「バックエンドの公開 API 設計が固まっていない」「DB 接続前提のローカル動作が難しい」といった阻害要因に縛られず、UI/UX を先に確立できる。

### 4. 履歴の保存先

- v1 では **クライアントローカル (`localStorage`)** に閉じる。
- 認証付きユーザーが導入されるまでは、サーバー側にユーザー単位の履歴を持つ意味が薄い。
- ストレージのデータは `quzzes:history:v1` キーに JSON で保存し、読み込み時に zod (`historyRecordsSchema`) で検証する。破損データは黙って空履歴に置き換え、`CustomEvent` でレイアウトに通知する。

### 5. 規約の踏襲

- ESLint 設定、`tsconfig.*`、Tailwind v4 のテーマ変数など、`admin-web/` と同一構成にすることで、レビュー基準とオンボーディングコストを共通化する。
- `docs/implement-policy.md`（実装ポリシー4）の React 7 原則（メモ化・状態最小化・更新関数パターン・遅延評価など）を新規コードでも踏襲する。

## Consequences

### Positive

- 管理画面とユーザー画面が独立にデプロイ・ビルドできる
- バックエンド改修なしに UI/UX 改善を進められる
- 履歴の永続化先を後から差し替え可能（`web/src/lib/historyStorage.ts` に閉じている）

### Negative

- 候補プール（`admin-web/src/data/quizzes.json`、437 問）と `web/src/data/quizzes.ts`（10 問）でデータが二重化している。次フェーズで以下のいずれかに統一する必要がある:
  1. `backend` に公開 API を追加し、両方をそこから取得する
  2. ルートに共通パッケージ（例: `quizzes-data/`）を作り、両者から import する
- LocalStorage はユーザーが端末・ブラウザ・プロファイルを切り替えると引き継がれない。本格運用時にはアカウント連携の履歴 API が必要。

## 移行の指針（Web 公開 API 追加時）

1. `backend` に `GET /api/quizzes` と `GET /api/quizzes/{id}` を **認証不要** で追加し、`status = 'published'` のみ返す
2. `web/src/api/quiz.ts` を新設し、`requestJson` と zod 検証で取得する（`admin-web/src/api/client.ts` と同じパターン）
3. `web/src/hooks/useQuizCatalog.ts` の `loadQuizzes()` を fetch 実装に差し替える
4. `STARTER_QUIZZES` はオフライン/フォールバック用途として `web/src/data/quizzes.ts` に残す

## 関連

- ADR 0002: Frontend Architecture Selection (SPA)
- ADR 0003: Styling with Tailwind CSS
- 実装ポリシー: `../implement-policy.md`
- データワークフロー: `../quiz-data-workflow.md`
