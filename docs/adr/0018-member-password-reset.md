# ADR 0018: 会員のパスワードリセット（email 追加）

- Status: Accepted
- Date: 2026-08-19
- Deciders: Quiz App Team
- Related: ADR 0016（会員アカウント）, ADR 0017（レート制限）, ADR 0004（管理者ログイン検証フロー）

## Context

ADR 0016 §Deferred で本 ADR を予定として明記していた。現在の会員スキーマは
ハンドル + パスワードハッシュのみで email を持たない。忘れたパスワードを取り戻す
手段が存在せず、実運用で会員維持ができない。

## Decision

email を**任意**カラムとして追加し、メール送信可能な会員に限りリセットを提供する。
email がない既存会員は「作り直し」を継続とする（ADR 0016 で許容済み）。

### 1. スキーマ変更

```sql
ALTER TABLE members
    ADD COLUMN email CITEXT,
    ADD COLUMN email_verified_at TIMESTAMPTZ;

CREATE UNIQUE INDEX members_email_active_uniq
    ON members (email)
    WHERE deleted_at IS NULL AND email IS NOT NULL;
```

- `email` は NULL 許容。既存会員に強制しない。
- 部分ユニークインデックスで**アクティブ会員内で email 重複禁止**（`handle` と同じ形）。
- `email_verified_at` は「検証完了」の記録。未検証の email ではリセットを実行しない。

### 2. 追加テーブル

```sql
CREATE TABLE password_reset_tokens (
    token_hash    TEXT        PRIMARY KEY,   -- SHA-256 の hex
    member_id     UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at    TIMESTAMPTZ NOT NULL,
    consumed_at   TIMESTAMPTZ
);
CREATE INDEX ON password_reset_tokens (member_id, created_at DESC);
CREATE INDEX ON password_reset_tokens (expires_at);
```

- **平文トークンは保存しない**。SHA-256 の hex を主キーにする。
- `expires_at` は発行から 30 分。
- `consumed_at` を立てて多重使用を防ぐ（一度リセット完了したら再利用不可）。

```sql
CREATE TABLE email_verification_tokens (
    token_hash    TEXT        PRIMARY KEY,
    member_id     UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    email         CITEXT      NOT NULL,   -- 検証対象の email（会員が後で変えても記録が残る）
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at    TIMESTAMPTZ NOT NULL,
    consumed_at   TIMESTAMPTZ
);
CREATE INDEX ON email_verification_tokens (member_id, created_at DESC);
```

同様に平文非保存、24 時間有効。

### 3. エンドポイント

すべて公開エラーフォーマット（ADR 0006 `{code, message}`）を返す。

| Method Path | 認証 | 用途 |
| --- | --- | --- |
| `POST /api/me/email` | member Bearer | email を設定 or 変更。検証メール送信 |
| `POST /api/email-verifications/{token}` | なし | 検証トークン消費 → `email_verified_at` 設定 |
| `POST /api/password-resets` | なし | `{handle_or_email}` を受け、検証済み email があればメール送信 |
| `POST /api/password-resets/{token}` | なし | `{token, newPassword}` を受け、パスワード再設定 |

- `POST /api/password-resets` は **常に 202 Accepted を返す**（列挙対策）。
  内部で「会員が存在する」「email 未登録」「未検証」でも同じ応答にする。
- `POST /api/password-resets/{token}` は成功で 204 No Content、失敗で 400。
  トークンは 1 度だけ使える（`consumed_at` を立てる）。

### 4. メール送信

- SES / SendGrid の**どちらか一方**を採用（実装 PR で決定）。本 ADR は「送信手段は
  設定可能な interface」とだけ決める。開発環境は stdout ログ（`log.Printf`）で代替。
- テンプレートは日本語 + 英語の 2 種類。テンプレートは Go の `text/template` で backend
  リポジトリに埋め込み。3rd party テンプレートエンジンを導入しない。
- **本番以外は絶対にメールを送らない**。`APP_ENV=production` でない限り stdout ログのみ。

### 5. レート制限

ADR 0017 のスライディングウィンドウを流用:

| Method Path | ウィンドウ | 上限 |
| --- | --- | --- |
| `POST /api/password-resets` | 1 時間 | IP: 5 / handle+email 組: 3 |
| `POST /api/password-resets/{token}` | 5 分 | IP: 10 |
| `POST /api/me/email` | 1 時間 | member: 3 |
| `POST /api/email-verifications/{token}` | 5 分 | IP: 10 |

member 単位の制限は Bearer で確定した `member_id` で数える。

### 6. ADR 0016 との差分（公開してよいフィールド）

`publicMember` に `email` / `emailVerifiedAt` を**含めない**。ADR 0016 §6 の禁止リスト
に相当。会員本人向けの取得エンドポイントを別途作るなら別 ADR。

email の**存在有無**は本人だけが知るべき情報なので、`GET /api/me` の応答には
`{id, handle, hasVerifiedEmail}` の boolean だけを追加する（実装 PR）。素の email は
決してレスポンスに含めない。

### 7. パスワードハッシュ移行

パスワードリセット完了時に、旧 bcrypt cost（12）で再ハッシュする。将来 argon2id へ
段階移行する（ADR 0016 で保留）ならば、その時点で「ログイン成功時に argon2id へ再ハッシュ」
のフックを入れる。本 ADR では扱わない。

## Consequences

### Good

- email を任意にしたので、既存の匿名寄り会員は影響を受けない。
- トークンは平文非保存 + 一度きり使用 + 期限 30 分 → 漏洩耐性が高い。
- ハンドル列挙が起きにくい（常に 202 Accepted）。

### Bad / Trade-offs

- email を持つ会員は SES/SendGrid の外部サービス依存が増える。
- メール到達性は運用問題（SPF/DKIM/DMARC 設定）で吸収する必要がある。
- email 変更フローは「新しい email を検証済みにするまで、リセットは旧 email で行う」
  という semantics。実装 PR で明示的にテストする。

### Deferred (別 ADR)

- SMS / パスキー（WebAuthn）ベースのリセット
- argon2id 移行（ADR 0016 で保留）
- admin 側の「メール送信履歴閲覧」ダッシュボード
- ソーシャルログイン（Google / GitHub OAuth）

## Implementation notes

- Migration 順は `019_add_members_email` → `020_create_password_reset_tokens` →
  `021_create_email_verification_tokens`。
- `packages/backend/mailer.go` で `type Mailer interface { Send(ctx, to, subject, body) error }`。
  `stdoutMailer`（dev）と `sesMailer`（prod）を実装。DI は `server` struct 経由。
- OpenAPI は `docs/api/member-api.yaml` に追記。
- 手書き Zod は `packages/web/src/schemas/member.ts` に追記。
- 契約テスト（fixtures）を成功 + 失敗の両方で用意する。

## Rejected alternatives

- **email を必須にする**: 既存会員が失格する。移行が必要。任意で開始し、必要になったら
  必須化 ADR を切る。
- **平文トークンを DB に保存**: DB 漏洩時に全会員のリセットが可能になる。SHA-256 hex で
  保存すれば、DB 漏洩でも消費前に検知・失効化できる。
- **JWT ベースのリセットトークン**: 失効管理が難しい（stateless）。DB で `consumed_at`
  を立てる方が one-time 使用を担保しやすい。
- **SMS / 電話番号 SMS 認証**: 国際化対応 + 料金 + 通信キャリア制約が多い。将来別 ADR。
- **メール本文にパスワードを平文送信**: 論外。却下。
