# Quiz Backend API

Go + PostgreSQL 製のクイズアプリ API サーバー。
`package main` を責務別ファイルに分割し、Public API・管理 API・認証・Seed 同期を提供する。

## 役割

| グループ | 認証 | 用途 |
| --- | --- | --- |
| System | なし | ヘルスチェック、PV カウンター |
| Public (`/v1/...`) | なし | 公開済みクイズの配信 |
| Admin (`/api/admin/...`) | JWT Bearer | 管理画面向け CRUD、Seed 同期 |

## クイックスタート（Docker Compose）

```bash
cd backend
docker compose up --build
```

| サービス | ホストからの URL |
| --- | --- |
| API | `http://localhost:8082` |
| PostgreSQL | `localhost:5433`（DB 名 `counter`） |

本番の公開 URL は **`https://socrates-quiz.jp`（HTTPS 443）**（コンテナ内は引き続き 8080）。

起動時に golang-migrate で `migrations/` を自動適用する。

## ローカル開発（Go 直実行）

### 1. PostgreSQL を起動する

```bash
cd backend
docker compose up -d db
```

### 2. 環境変数を用意する

```bash
cp .env.example .env
# 必要に応じて .env を編集
```

または対話的に生成する:

```bash
python3 ../scripts/create_backend_env.py
```

Go は `.env` を自動読み込みしない。`go run .` の前に export する:

```bash
set -a && source .env && set +a && go run .
```

| 変数 | ローカル既定値 | 説明 |
| --- | --- | --- |
| `DB_HOST` | `localhost` | PostgreSQL ホスト |
| `DB_PORT` | `5433` | PostgreSQL ポート |
| `DB_USER` | `postgres` | DB ユーザー |
| `DB_PASSWORD` | `password` | DB パスワード |
| `DB_NAME` | `counter` | データベース名 |
| `ADMIN_USER` | `admin` | 管理者ユーザー名 |
| `ADMIN_PASSWORD` | `password` | 管理者パスワード |
| `JWT_SECRET` | `dev-only-secret` | JWT 署名鍵 |
| `QUIZ_SEED_GENERATOR_SCRIPT` | `../scripts/generate_migration.py` | Seed SQL 生成スクリプト |
| `QUIZ_PYTHON_BIN` | `python3` | Seed 同期時に使う Python |
| `QUIZ_MIGRATIONS_DIR` | `migrations` | migration SQL のディレクトリ |

テンプレートは [`backend/.env.example`](.env.example) を参照。

### 3. サーバーを起動する

```bash
cd backend
go run .
```

コンテナ内開発では Air によるホットリロードが有効（`docker compose up`）。

## API 一覧

### System

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/`, `/healthz` | ヘルスチェック |
| GET | `/counter` | PV カウンター取得 |
| POST | `/counter` | PV カウンター加算 |

### Public API

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | `/v1/quizzes` | 公開クイズ一覧（`section`, `limit` 可） |
| GET | `/v1/quizzes/{id}` | 公開クイズ個別取得 |
| GET | `/v1/sections` | セクション一覧（件数付き） |

### Admin API（JWT 必須）

| メソッド | パス | 説明 |
| --- | --- | --- |
| POST | `/api/admin/login/verification` | 検証コード発行 |
| POST | `/api/admin/login` | ログイン（JWT 発行） |
| GET | `/api/admin/quizzes` | クイズ一覧 |
| POST | `/api/admin/quizzes` | クイズ作成 |
| GET | `/api/admin/quizzes/{id}` | クイズ取得 |
| PUT | `/api/admin/quizzes/{id}` | クイズ更新 |
| DELETE | `/api/admin/quizzes/{id}` | クイズ削除 |
| PATCH | `/api/admin/quizzes/{id}/status` | 公開状態トグル |
| PATCH | `/api/admin/quizzes/{id}/push` | Push 通知トグル |
| POST | `/api/admin/quizzes/sync-production` | 本番 Seed 同期 |
| POST | `/api/admin/push/dispatch` | mock Push 手動送信 |
| GET | `/api/admin/push/deliveries` | mock Push 配信履歴 |

公開 API の OpenAPI ドラフト: [`docs/api/public-quiz-api.yaml`](../docs/api/public-quiz-api.yaml)

## ディレクトリ構成

```
backend/
  main.go              # 起動・CORS・ルーティング
  types.go             # DTO / server
  db.go                # PostgreSQL・migrate
  httpx.go             # JSON / parseID / 公開エラー
  auth.go              # JWT・ログイン検証コード
  counter.go           # / /counter
  admin_quizzes.go     # /api/admin/quizzes*
  public.go            # /v1/*（公開）
  push.go              # mock Push
  seed.go              # 本番シード同期
  quiz_scan.go         # Scan ヘルパー
  debug.go             # 起動時メモリ診断
  migrations/          # golang-migrate SQL（embed も可）
  seeds/
    quizzes.production.json   # 本番 Seed テンプレート
  docker-compose.yml
  Dockerfile
  .air.toml            # 開発用ホットリロード設定
```

## 品質チェック

CI（`.github/workflows/backend.yml`）と同じコマンド:

```bash
cd backend
gofmt -l .
go vet ./...
go build ./...
go test ./... -count=1
```

試し書きは `play.go`（`//go:build ignore`。`go build` には入らない）。`go run play.go`。

## 関連ドキュメント

- 要件定義: [`../quiz.md`](../quiz.md)
- ドキュメント索引: [`../docs/INDEX.md`](../docs/INDEX.md)
- システム構成: [`../docs/architecture/overview.md`](../docs/architecture/overview.md)
- リクエストフロー: [`../docs/architecture/backend-flow.md`](../docs/architecture/backend-flow.md)
- データモデル: [`../docs/architecture/data-model.md`](../docs/architecture/data-model.md)
- PV カウンター API: [`../docs/counter-api.md`](../docs/counter-api.md)
- クイズデータ運用: [`../docs/quiz-data-workflow.md`](../docs/quiz-data-workflow.md)
