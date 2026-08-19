# ADR 0016: 会員アカウント（admin と分離）

- Status: Accepted
- Date: 2026-08-18
- Deciders: Quiz App Team
- Related: ADR 0004（login verification flow）, ADR 0005, ADR 0006, ADR 0008

## Context

`publicQuiz` は誰でも読める匿名 API として設計されている（ADR 0006 / `docs/detailed-design/web/public-contract.md`）。
回答履歴は現状、端末ローカル（`localStorage` / `shared_preferences`）と匿名 `attempts` 送信の二段構え（ADR 0008）で扱っている。

今回、利用ユーザーが端末をまたいで「自分の回答履歴」を持てるようにしたい。ここで最初に決めておかないと、次のような後戻りしづらい失敗が起きる。

- 匿名の `publicQuiz` に会員向けフィールド（例: `answeredByMe`）が漏れる
- 管理者 JWT を会員に流用してしまう
- email など不要な PII をいきなり抱え込む

## Decision

### 1. 認証は会員専用 JWT（admin JWT と分離）

- `packages/backend` は admin JWT とは**別鍵**で会員 JWT を発行・検証する。
- 会員 JWT の `sub` は `members.id`、`aud` は `"member"`。
- admin JWT (`aud: "admin"` 相当) を会員エンドポイントで受理してはならない。逆も同様。
- 鍵は環境変数を分ける（`MEMBER_JWT_SECRET`）。**同じ秘密鍵を共有しない。**

理由: 権限昇格を鍵の混同で起こさない。admin を止めても会員は生き続けるし、逆も然り。

### 2. API 系統を分ける（`publicQuiz` に会員フィールドを混ぜない）

- 会員向けは `/api/me`, `/api/me/answers` などの `me` 名前空間。
- 公開 `publicQuiz` / `publicQuizListResponse` の JSON 形状は**一切変えない**。
- 「そのクイズに自分が回答したか」は `GET /api/me/answers?quizId=...` で解決する。`publicQuiz` に `answeredByMe` は生やさない。
- OpenAPI は同じ `docs/api/public-quiz-api.yaml` に追記するが、既存の匿名 `publicQuiz` スキーマは変更禁止。

理由: 匿名 API のキャッシュ性・単純さを維持する。`publicQuiz` の SSOT（OpenAPI + fixtures + Zod + Go）を触らずに済む。

### 3. 初期の会員属性はハンドル + パスワードハッシュのみ

- `members` テーブル初期スキーマ:
  - `id UUID PRIMARY KEY` — **UUID v7** で発行（時系列ソート可）
  - `handle CITEXT NOT NULL`（3–32 文字、`^[a-zA-Z0-9_]+$`）
  - `password_hash TEXT NOT NULL` — **bcrypt cost 12**
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
  - `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`
  - `deleted_at TIMESTAMPTZ NULL`
- `handle` の一意制約は部分インデックスで表現し、ソフト削除後の再利用を許す:
  `CREATE UNIQUE INDEX members_handle_active_uniq ON members (handle) WHERE deleted_at IS NULL;`
- email, 表示名, アバター URL などは**この ADR では持たない**。必要になった時点で別 ADR。

### 4. 回答履歴の SSOT は PostgreSQL `answer_history`

既存の `quizzes.id` は `BIGSERIAL`（ADR 0006 / `001_create_tables.up.sql`）なので、`quiz_id` は `BIGINT` で参照する。

```sql
CREATE TABLE answer_history (
    id             BIGSERIAL PRIMARY KEY,
    member_id      UUID    NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    quiz_id        BIGINT  NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    selected_index INT     NOT NULL CHECK (selected_index >= 0),
    answered_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON answer_history (member_id, answered_at DESC);
CREATE INDEX ON answer_history (member_id, quiz_id);
```

- 「正誤」はカラムに持たない。`quizzes.correct_answer_index` と JOIN して都度算出する（正解が後から訂正された場合に自動追従させるため）。
- 同一クイズに何度も答えられる（履歴を潰さない）。「最新の回答」を出す UI はクエリで解決する。
- 既存の匿名 `attempts` / `attempt_answers`（ADR 0008）は**残す**。両者は目的が違う（匿名集計 vs 個人履歴）。将来の統廃合は別 ADR。

### 5. 削除はソフト削除（`deleted_at`）

- `DELETE /api/me` は `members.deleted_at = now()` を立てるだけ。
- ハンドルは即時解放してよい（他人が同じハンドルで再登録できる）。上記の部分ユニークインデックスで表現する。
- `answer_history` は `ON DELETE CASCADE` だが、ソフト削除では消えない。会員がハード削除を要求した場合の運用は将来別 ADR。
- ログインおよびすべての `/api/me` 系エンドポイントは `deleted_at IS NOT NULL` の会員を 401 として扱う。

### 6. 公開してはいけないフィールド（`publicQuiz` と同じルール）

会員 API のレスポンス (`publicMember`) に**含めてはならない**:

- `password_hash`
- `created_at`, `updated_at`, `deleted_at`
- 他会員の `id` / `handle`（自分以外の会員情報は返さない。ランキング等を作る時は別 ADR）

公開してよいのは `id`, `handle` のみ（`GET /api/me` の場合）。

## Consequences

### Good

- `publicQuiz` の匿名キャッシュ性と SSOT が保たれる。
- admin 鍵漏洩と会員鍵漏洩が独立する。
- PII 面積が最小。
- 正解訂正が過去の履歴の正誤に自動反映される。

### Bad / Trade-offs

- 「同じクイズに以前答えたか」を知るのに追加リクエストが要る（`publicQuiz` に埋めれば 1 往復で済む）。→ キャッシュ性優先で受け入れる。
- パスワードリセット手段がない（email を持たないため）。→ 初期は「忘れたら作り直し」で許容。email 追加は別 ADR。
- ハンドル再利用を許すため、過去のスクショで別人と混同されうる。→ UI 側で「このハンドルは現在の会員のもの」と明示。

### Deferred（別 ADR で扱う）

- **ログインのレート制限**: 本 ADR のスコープ外。実装 PR (PR-B) でも入れない。将来、ブルートフォース対策 ADR を切って IP + ハンドル単位のスライディングウィンドウ等を検討する。
- パスワードリセット（email 前提）
- 会員のハード削除運用
- ランキング等、他会員情報を公開する機能
- 匿名 `attempts` と会員 `answer_history` の統廃合

## Follow-up PRs

この ADR が入ったあと、以下の順で分割する:

- **PR-B**: `members` テーブル、`/api/members`（登録）、`/api/session`（ログイン、会員 JWT 発行）、`packages/backend/*_test.go`。公開契約 (`publicQuiz`) は触らない。
- **PR-C**: `/api/me`, `/api/me/answers`（回答履歴） + OpenAPI 追記 + `docs/api/fixtures/` + `packages/web/src/schemas/member.ts`（手書き Zod）+ 契約テスト。
- **PR-D**: `packages/web/` に登録・ログイン・履歴 UI。
- **PR-E**: `packages/mobile/lib/layers/data/dto/public_member_dto.dart` と画面。

## Rejected alternatives

- **admin JWT の流用**: 権限昇格リスク。却下。
- **`publicQuiz` に `answeredByMe` を生やす**: 匿名 API のキャッシュ性と SSOT を壊す。却下。
- **email を初期スキーマに含める**: 使い道がまだ無いのに PII を抱える。必要になった時点で別 ADR。
- **ハード削除**: 誤操作の巻き戻しが不可能。ソフト削除で開始し、ハード削除は要求ベースの運用で足す。
- **`answer_history` に `is_correct` カラムを持つ**: 正解訂正時に過去データが古い正誤のまま残る。JOIN で都度算出する。
- **argon2id をこの PR で採用**: Go 側の依存追加が要り、PR-B のスコープが膨らむ。bcrypt cost 12 で開始し、将来 ADR で argon2id 移行を検討する（既存ハッシュはログイン時に段階移行）。
