# Counter API 実装メモ

PV カウンター API（`GET /counter`, `POST /counter`）の実装詳細。
アーキテクチャ方針は [ADR 0001](./adr/0001-counter-api-architecture.md) を正本とする。

## 概要

| 項目 | 内容 |
| --- | --- |
| エンドポイント | `GET /counter`, `POST /counter` |
| 永続化 | PostgreSQL `views` テーブル（singleton 行 `id = 1`） |
| ハンドラ | `backend/counter.go` の `handleGetCounter`, `handleIncrementCounter` |
| 用途 | ページビュー数（PV）の取得・加算 |

API パスは `/counter` だが、永続テーブル名は `views` である。初期 ADR では `counters` テーブルを想定していたが、
migration `001_create_tables.up.sql` 以降は `views` に統一している。

## エンドポイント

### `GET /counter`

現在の PV 数を返す。

**成功（200）**

```json
{ "count": 42 }
```

**失敗**

| ステータス | 条件 | レスポンス例 |
| --- | --- | --- |
| 404 | `views` に `id = 1` の行がない | `{ "error": "counter not found" }` |
| 500 | DB エラー | `{ "error": "<detail>" }` |

### `POST /counter`

PV を 1 加算し、更新後の値を返す。

**成功（200）**

```json
{ "count": 43 }
```

**失敗**

| ステータス | 条件 | レスポンス例 |
| --- | --- | --- |
| 404 | 対象行が存在しない | `{ "error": "counter not found" }` |
| 500 | DB エラー | `{ "error": "<detail>" }` |

## データベース

### スキーマ

```sql
CREATE TABLE IF NOT EXISTS views (
    id    INT PRIMARY KEY,
    count INT NOT NULL
);

INSERT INTO views (id, count)
VALUES (1, 0)
ON CONFLICT (id) DO NOTHING;
```

| カラム | 型 | 役割 |
| --- | --- | --- |
| `id` | `INT` | カウンター識別子。常に `1` |
| `count` | `INT` | 現在の PV 値 |

### SQL

**取得**

```sql
SELECT count FROM views WHERE id = 1;
```

**加算（原子更新）**

```sql
UPDATE views SET count = count + 1 WHERE id = 1 RETURNING count;
```

並行リクエストは DB の原子更新に委ねる。アプリ側の `sync.Mutex` は使わない。

## CORS

`withCORS` が全ルートの最外周を包む。

- リクエストに `Origin` ヘッダがある場合、その値を `Access-Control-Allow-Origin` にそのまま反映する
- `Vary: Origin` を付与する
- `OPTIONS` はハンドラ本体に入る前に `204 No Content` で返す

ADR 0001 では開発向けにオリジン whitelist を採用する方針だったが、
Vite がポートを自動変更する（5173 → 5174 など）ローカル開発の都合から、現実装は Origin 反射に寄せている。
本番公開時は許可オリジンの allowlist 化を再検討する。

## ローカル確認

Docker Compose 起動後（ホストからは `http://localhost:8082`）:

```bash
curl -s http://localhost:8082/counter
curl -s -X POST http://localhost:8082/counter
```

## 関連ドキュメント

- [ADR 0001: Counter API Architecture](./adr/0001-counter-api-architecture.md)
- [バックエンドリクエストフロー](./architecture/backend-flow.md)
- [データモデル](./architecture/data-model.md)
- [`backend/README.md`](../backend/README.md)
