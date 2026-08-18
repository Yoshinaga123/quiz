# クイズデータワークフロー

## 概要

クイズの問題データは「Git 上の問題ファイル」と「本番 DB」の 2 層で管理する。公開可否は `quizzes.json` の `published` で選ぶ。

| 層 | 保管場所 | 役割 |
|---|---|---|
| 問題ファイル | `packages/admin-web/src/data/quizzes.json` | 下書きと採用済みを同じファイルに置く。`published: true` だけがシード対象 |
| 本番データ | PostgreSQL `quizzes` テーブル | ユーザーに配信する問題。管理画面から登録・編集する |

## データの流れ

```
quizzes.json
    │
    │  新しい問題は published: false で追加
    │  管理画面の JsonQuizPreviewSection で確認
    │
    ▼
採用する問題の published を true にする
    │
    │  シード SQL 生成の入力は published: true だけ
    │
    ▼
スクリプトで SQL 生成
    │
    │  例: `python3 scripts/create_seed_migration.py --no-down`
    │       → 初回は `packages/backend/migrations/001_create_tables.up.sql`
    │
    ▼
PostgreSQL quizzes テーブル（本番データ）
    │
    │  API 経由で配信（DB の status = published のみ）
    │
    ▼
ユーザー向けアプリ
```

## quizzes.json の位置づけ

- Git 上の問題文の正本である
- すべての問題がシードされるわけではない。`published: true` だけが対象
- MDN Web Docs などの出典に基づいて作成し、正確性を確認した上で追加する
- 管理画面プレビュー用にフロントへ埋め込まれるが、ユーザー向け配信には使わない

### JSON の構造

```json
{
  "quizzes": [
    {
      "id": 1,
      "section": "CSS",
      "title": "タイトル",
      "question": "問題文",
      "code": "コードブロック（任意）",
      "options": ["選択肢1", "選択肢2", "選択肢3", "選択肢4"],
      "correctAnswerIndex": 0,
      "explanation": "解説",
      "source": "出典 URL",
      "published": false
    }
  ]
}
```

`published` はシード対象の選別だけに使う。公開 API の `publicQuiz` には出さない。DB の `status` と `push_enabled` はシード時に上書きしない。

## PostgreSQL quizzes テーブルの位置づけ

- **本番環境の Single Source of Truth（正）** である
- 管理画面の CRUD 操作はすべてこのテーブルに対して行う
- `status`（published / unpublished）で公開状態を制御する
- `push_enabled` で PUSH 通知配信の対象を制御する

## 関連するコンポーネント

| ファイル | 役割 |
|---|---|
| `packages/admin-web/src/data/quizzes.json` | 問題ファイルの実体 |
| `packages/admin-web/src/types/quiz.ts` | JSON 用の型定義 |
| `packages/admin-web/src/components/JsonQuizPreviewSection/quizUtils.ts` | JSON からの読み取り・検索・統計計算 |
| `packages/admin-web/src/components/JsonQuizPreviewSection/index.tsx` | JSON プレビュー表示 |
| `packages/admin-web/src/types/admin.ts` | DB 連携用の型定義 |
| `packages/admin-web/src/api/admin.ts` | DB 連携用の API クライアント |
| `scripts/generate_migration.py` | seed JSON から `up/down` SQL テキストを生成（`published: true` のみ） |
| `scripts/create_seed_migration.py` | `golang-migrate create` と SQL 書き込みを自動化 |

## 運用ルール

1. 新しい問題を思いついたら、まず `quizzes.json` に `published: false` で追加する
2. 管理画面のプレビュー機能で問題文・選択肢・解説の品質を確認する
3. 本番採用が決まった問題だけ `published` を `true` にする
4. 管理画面の「quizzes.json を DB 反映」ボタン、または `scripts/create_seed_migration.py` で migration を生成する
5. 生成した migration を適用して DB に反映する
6. 管理画面ボタンの同期は replace モードで動作し、`published: true` に存在しないクイズは DB から削除される
7. DB 登録後、必要なら管理画面で `status` を `published` に切り替えて配信対象にする
8. 下書きは削除せず、`published: false` のまま残す

## マイグレーション生成コマンド

### 推奨

```bash
python3 scripts/create_seed_migration.py
```

- `migrate create -ext sql -dir packages/backend/migrations -seq -digits 3 seed_quizzes` を内部で実行する
- 生成された `NNN_seed_quizzes.up.sql` に Upsert SQL を書き込む
- 生成された `NNN_seed_quizzes.down.sql` には、今回の seed 対象 ID を削除する簡易ロールバック SQL を書き込む
- 片方向マイグレーションとして扱いたい場合だけ `--no-down` を付ける

### その場で適用する場合

```bash
DATABASE_URL='postgres://postgres:password@localhost:5433/counter?sslmode=disable' \
python3 scripts/create_seed_migration.py --apply
```

- `--apply` はファイル生成後に `migrate -path packages/backend/migrations -database "$DATABASE_URL" up` を実行する
- `packages/backend/docker-compose.yml` のローカル DB を使う場合は上記 URL で接続できる

## ロールバックの注意点

- `down.sql` は今回 seed に含まれる ID を削除する簡易ロールバックであり、更新前データの完全復元ではない
- 片方向マイグレーションとして扱いたい場合は `--no-down` を付けて生成し、必要な訂正は次の seed マイグレーションで行う
- 既存データの履歴復元まで必要なら、別途バックアップか専用の復元マイグレーションが必要

## 管理画面ボタンの同期仕様

- `quizzes.json を DB 反映` ボタンは `packages/admin-web/src/data/quizzes.json` の `published: true` から新しい migration を生成して適用する
- 生成される migration ファイルは `packages/backend/migrations/NNN_seed_quizzes.up.sql` / `.down.sql`
- `published: true` の ID は Upsert される
- それに含まれない ID は DB から削除される
- シード対象が空なら `quizzes` テーブルは全件削除される
