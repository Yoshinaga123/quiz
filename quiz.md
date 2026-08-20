# クイズアプリ要件定義

高難度の IT クイズを、**ユーザー向け Web**・**Flutter**・**管理 Web**・**Go API** で提供する。

## 目的

- コードの意味を問う問題と、公式ドキュメント英文の日本語訳問題を出す。
- 選択肢は複数、正解は 1 つ。出典は高品質な公式ドキュメント。
- ユーザーは登録なしでも解ける。任意で会員登録すると回答履歴を端末間で共有できる。管理者だけが問題を CRUD する。

## 機能要件

### ユーザー（web / mobile）

- 問題と選択肢の表示、解答、結果（解説・出典）
- 匿名時の履歴・正答率は端末ローカル（`localStorage` / `shared_preferences`）
- 匿名回答は best-effort で `POST /v1/attempts` に送信（集計用、[ADR 0008](docs/adr/0008-anonymous-attempts.md)）
- 会員機能は任意（[ADR 0016](docs/adr/0016-member-accounts.md)）
  - ハンドル + パスワードで登録・ログイン（`/api/members`, `/api/session`）
  - 端末間で共有する回答履歴（`/api/me/answers`）
  - メールアドレス登録によるパスワードリセット（`/api/me/email`, `/api/password-resets`）
  - ソフト削除（`DELETE /api/me`）
  - 会員 JWT は管理者 JWT と別鍵で発行し、`publicQuiz` の JSON 形状には会員フィールドを混ぜない

### 管理者（admin-web）

- クイズの追加・編集・削除、公開状態、Push フラグ
- ログインは検証コードフロー（メッセージ: 「quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。」）
- mock Push 送信（Phase A。本物の FCM / APNs は未実装）

### バックエンド

- 公開: `GET /v1/quizzes`, `/v1/quizzes/{id}`, `/v1/sections`, `/v1/push/feed`, `POST /v1/attempts`, `GET /healthz`
- 会員: `/api/members`, `/api/session`, `/api/me`, `/api/me/answers`, `/api/me/email`, `/api/email-verifications/{token}`, `/api/password-resets`（会員 JWT Bearer）
- 管理: `/api/admin/*`（管理者 JWT Bearer）
- データ正本: PostgreSQL `quizzes` / `members` / `answer_history`
- 候補プール → 本番シード → DB の 3 層（`docs/quiz-data-workflow.md`）

## 画面

- 出題（英文読解 / コード）
- 結果（解説）
- 履歴（正答率）
- 会員: 登録・ログイン・プロフィール（任意利用）
- 管理: 一覧・作成・編集

## 技術スタック（実装準拠）

| 領域 | 実装 |
| --- | --- |
| ユーザー Web | React 19 + TypeScript 5.9 + Vite 7 + Tailwind CSS v4 + Zod |
| 管理 Web | 同上 + SWR |
| モバイル | Flutter / Dart 3.3+ / Riverpod / shared_preferences / flutter_local_notifications |
| 状態（Web） | `useState` / Context |
| ルーティング（Web） | react-router-dom v7（History API） |
| API | Go 1.26 **`net/http`**（Echo ではない）+ PostgreSQL 16 |
| 認証 | 管理者 JWT（検証コードフロー）+ 会員 JWT（`MEMBER_JWT_SECRET` で別鍵、`aud: "member"`、bcrypt cost 12） |
| コンテナ | Docker Compose（API ホスト 8082 → コンテナ 8080） |
| バリデーション | Zod（web / admin-web）。公開契約は OpenAPI 3.1 |
| 品質 | ESLint、Vitest（web / admin-web）、go test、Redocly |
| Push | Phase A: mock feed + ローカル通知。FCM / APNs は ADR 0007（Proposed） |

本番公開 URL: `https://socrates-quiz.jp`（HTTPS 443）。置き場は Lightsail 1台（[ADR 0015](docs/adr/0015-lightsail-production.md)）。詳細は [`README.md`](README.md) と [`docs/INDEX.md`](docs/INDEX.md)。

## 開発規約

- ESLint に従う。コンポーネントは機能ごとに分割する。
- AI 生成コードは開発者が理解してから入れる。
- クイズ本文は公式ドキュメント由来で、正確・最新であること。
- 公開 API の shape を変えたら OpenAPI・Zod・テストを同じ PR で直す（[`CONTRIBUTING.md`](CONTRIBUTING.md)）。
- 会員 API の shape を変えたら [`docs/api/member-api.yaml`](docs/api/member-api.yaml)・Zod（[`packages/web/src/schemas/member.ts`](packages/web/src/schemas/member.ts)）・Flutter DTO・契約テストを同じ PR で直す。
- `publicQuiz` に会員向けフィールド（`answeredByMe` など）を混ぜない（[ADR 0016](docs/adr/0016-member-accounts.md) §2）。
