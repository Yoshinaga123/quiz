# ADR 0008: ユーザー回答履歴の保存方式

- Status: Proposed
- Date: 2026-04-21
- Deciders: Quiz App Team
- Related: ADR 0005, ADR 0006

## Context

`web/` ではすでに **`localStorage` ベースの履歴保存** を実装済み（`web/src/lib/historyStorage.ts`）。
一方で次の要望が想定される。

- 端末を変えても履歴を引き継ぎたい。
- セクション別正答率の母集団分析を運営側で確認したい。
- ユーザー登録（メール / SSO）はできれば避けたい（プライバシーと運用コスト）。

## Decision

履歴は **二段構え** で扱う。

1. **端末ローカル履歴（一次ソース）**: `localStorage` / モバイル側の `shared_preferences` 等。
   個人体験のために常に保持する。匿名のままで問題ない。
2. **サーバーへの匿名集計送信（二次ソース・任意）**: `POST /v1/attempts`（ADR 0006）に
   クライアントが生成する `clientSessionId`（UUID v4）を冪等キーとして送信する。
   サーバーは匿名 ID と回答結果のみを保存し、ユーザー特定情報は持たない。

ユーザー登録機構は v1 では導入しない。

## Schema (server side)

```sql
CREATE TABLE attempts (
  client_session_id UUID PRIMARY KEY,
  section TEXT,
  completed_at TIMESTAMPTZ NOT NULL,
  total_count INT NOT NULL,
  correct_count INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE attempt_answers (
  client_session_id UUID NOT NULL REFERENCES attempts(client_session_id) ON DELETE CASCADE,
  quiz_id BIGINT NOT NULL REFERENCES quizzes(id),
  selected_index INT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  answered_at TIMESTAMPTZ,
  PRIMARY KEY (client_session_id, quiz_id)
);
```

- `client_session_id` を主キーにすることで **冪等な再送** に対応。
- 個人特定情報（名前 / メール / IP）は保存しない。
- `attempt_answers` の集計で「クイズごとの正答率」をダッシュボードに供給できる。

## Consequences

### Positive

- ユーザーは登録なしで履歴と統計を享受できる。
- 端末を超えた履歴同期は **諦める** ことで、認証・パスワード復旧・GDPR 等の運用負荷を回避できる。
- 運営側はクイズの難易度バランス（正答率分布）を匿名データから観測できる。

### Negative

- 端末紛失・キャッシュ削除で履歴は失われる。これはユーザーに UI 上で明示する。
- 「自分の履歴をサーバーから削除したい」という要求にはセッション ID 単位でしか応えられない。
  UX として「セッション ID をエクスポート」する機能を後続で追加する。

## Migration

1. `web/` は ADR 0005 の通り `localStorage` を一次ソースとして既に動作している。
2. ADR 0006 の `POST /v1/attempts` 実装後、結果画面送信時に **best-effort** で送る（失敗は UI 体験を妨げない）。
3. モバイル版でも `clientSessionId` を導入し、同 API を呼ぶ。
