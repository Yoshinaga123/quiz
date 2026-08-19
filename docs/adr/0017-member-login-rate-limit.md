# ADR 0017: 会員ログインのレート制限

- Status: Accepted
- Date: 2026-08-19
- Deciders: Quiz App Team
- Related: ADR 0004（管理者ログイン検証フロー）, ADR 0016（会員アカウント）

## Context

ADR 0016 §Deferred で本 ADR を予定として明記していた。会員登録 `POST /api/members` と
ログイン `POST /api/session` は現在レート制限なしで実装されている（`packages/backend/members.go`）。

放置した場合の想定される攻撃:

- **オンライン辞書攻撃**: 同一ハンドルに対して 1 秒に数百回のパスワード試行
- **ハンドル列挙**: `POST /api/members` の 409 応答（既存ハンドル）と 201 応答（新規）で
  会員の存在を推測できる
- **会員登録濫用**: 使い捨てハンドルの大量作成でハンドル空間を汚染し、`answer_history`
  にゴミを積む

管理者ログイン（ADR 0004）は verification code 二段階が事実上のレート制限になっているが、
会員ログインは単純な `handle + password` なので保護が薄い。

## Decision

**バックエンド一段のスライディングウィンドウ**でレート制限を入れる。CDN 側やアプリケーション
ロードバランサー側の制限は将来の別 ADR で足す（本 ADR では前提としない）。

### 1. 対象エンドポイント

| Method Path | ウィンドウ | 上限 |
| --- | --- | --- |
| `POST /api/session` | 5 分 | IP: 20 / ハンドル: 5（**成功しない** 試行のみカウント） |
| `POST /api/members` | 1 時間 | IP: 10 |
| `POST /api/admin/login` | 5 分 | IP: 20 / ユーザー: 5 |
| `POST /api/admin/login/verification` | 5 分 | IP: 20 |

- カウントは**失敗した試行のみ**。成功したログインは減算しない（正当なユーザーが締め出されない）。
- 上限超過時は `429 Too Many Requests`、`Retry-After` ヘッダ（秒）、公開 API エラー
  フォーマット `{"code":"rate_limited","message":...}`（ADR 0006）を返す。
- **タイミングアタックを増やさない**ため、レート制限のチェックはパスワード検証と同じ順序で
  ハッシュ比較を実行してから制限判定する（`401` と `429` の分岐で応答時間が変わらないよう
  に、bcrypt 比較を先に走らせる）。

### 2. IP アドレスの取得

- 本番は AWS Lightsail の nginx 経由（ADR 0015）。`X-Forwarded-For` の**右端 1 個**を
  信頼する（左端は攻撃者が偽装できる）。
- 環境変数 `TRUSTED_PROXY_HOPS`（既定 1）で経由するリバースプロキシ段数を指定する。
- ローカル開発では `X-Forwarded-For` が空なら `RemoteAddr` にフォールバックする。

### 3. ストレージ

**PostgreSQL の既存 `login_logs` テーブルを流用**する（ADR 0004）。追加インデックス:

```sql
CREATE INDEX IF NOT EXISTS idx_login_logs_username_created
    ON login_logs (username, success, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_login_logs_ip_created
    ON login_logs (ip_address, success, created_at DESC);
```

- Redis を導入しない。本サービスは 1 インスタンス（ADR 0015）なので Redis の運用コスト
  に対して得るものが少ない。将来スケールアウトする際に別 ADR で移す。
- 会員向けには `member_login_logs` を新設する（`login_logs` は admin の PII を含むため
  同居させない）:

```sql
CREATE TABLE member_login_logs (
    id          BIGSERIAL PRIMARY KEY,
    handle      CITEXT      NOT NULL,   -- ハンドルは存在確認済み・未確認どちらも記録
    success     BOOLEAN     NOT NULL,
    ip_address  TEXT        NOT NULL,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX ON member_login_logs (handle, success, created_at DESC);
CREATE INDEX ON member_login_logs (ip_address, success, created_at DESC);
```

`handle` は `members.handle` への FK にはしない。存在しないハンドルへの試行も記録するため。

### 4. ハンドル列挙対策

- `POST /api/members` の 409（重複）と 400（バリデーション）は**同じ応答時間の分布**にする
  （bcrypt を実行してから返す）。
- 409 のメッセージは "handle already taken" で固定。`created_at` などは決して漏らさない
  （ADR 0016 §6 で既に禁止）。
- IP レート制限（10 req/hour）が主対策。

### 5. 会員登録の濫用対策

`POST /api/members` の IP 制限（10 / hour）で十分とする。CAPTCHA は導入しない
（依存追加を避ける、UX を落とす、bot 検出は別 ADR）。

### 6. 監視 / ロック解除

- `member_login_logs` の失敗上位を admin ダッシュボードに露出する導線は本 ADR では作らない
  （実装コストが割に合わない）。将来 `packages/admin-web/` で `/api/admin/member-lockouts`
  を作るかは別 ADR。
- 手動ロック解除の運用手段は**存在しない**。会員の締め出しは自動でウィンドウが経過すれば
  解除される。email がないため、外部チャネルで本人確認する術がない。

## Consequences

### Good

- スライディングウィンドウで単純・単一インスタンスの制約に適合。
- 既存インフラ（PostgreSQL）だけで完結し、Redis / CAPTCHA / 3rd party を持ち込まない。
- **失敗のみカウント**なので正当なユーザーが締め出されにくい。

### Bad / Trade-offs

- **単一インスタンス前提**。ADR 0015 で 1 インスタンスと決めた前提が崩れたら本 ADR も再考。
- IP ベース制限は NAT 配下の複数ユーザーが同一 IP を共有する場合に**巻き添え**が出る。
  ウィンドウ 5 分・IP 上限 20 で通常利用は妨げないと判断。
- タイミング攻撃を「同じ順序で bcrypt 実行」で緩和するが、完全ではない。定数時間比較への
  移行は将来の別 ADR。

### Deferred (別 ADR)

- CAPTCHA / bot 検出
- CDN / ALB 側のレート制限
- Redis バックエンド化（スケールアウト時）
- 手動ロック解除の運用フロー（email 追加 = ADR 0018 とセット）

## Implementation notes

- 実装 PR では `packages/backend/rate_limit.go` に汎用スライディングウィンドウ関数を置く。
  `handleCreateMemberSession` / `handleRegisterMember` / `handleLogin` のそれぞれから呼ぶ。
- 単体テストは sqlmock で `WillReturnRows` にダミー件数を返し、閾値の境界（19/20, 20/20,
  21/20）を検証する。

## Rejected alternatives

- **メモリ内のスライディングウィンドウ**: 再起動でリセットされ、監査ログにもならない。
  低コストだが得るものが少ない。却下。
- **失敗と成功の両方をカウント**: 正当なユーザーが締め出されうる。却下。
- **CAPTCHA を初期に導入**: フロントエンドの依存が増える、UX が落ちる。IP + ハンドル
  レート制限で足りると判断。CAPTCHA は将来 bot 対策 ADR で。
- **Redis バックエンド**: 単一インスタンスに対して過剰。運用コストが割に合わない。
