# スクリプト学習課題

現在のクイズアプリを調べたうえで、「次にあると便利なスクリプト」を学習用の課題として整理した。

## 調査結果の要約

- `scripts/` にはすでにクイズデータ運用向けの補助がある
  - `lint_quizzes.py`: JSON 構造チェック
  - `diff_quiz_data.py`: 候補プールと production seed の差分確認
  - `check_quiz_drift.py`: production seed と最新 migration の drift 検出
  - `create_seed_migration.py`: seed migration 作成補助
  - `create_backend_env.py`: `backend/.env` の生成補助
- 一方で、日常開発の入口になる「横断スクリプト」はまだ薄い
  - ルート `package.json` に共通の `scripts` がない
  - `web/` と `admin-web/` はそれぞれ `dev/build/lint` のみ
  - `backend/` は CI で `gofmt / go vet / go build / go test` を回しているが、ローカル用のまとめ入口はない
  - `docs/api/public-quiz-api.yaml` はあるが、ローカルで叩く簡易スモークチェックはない
- データの流れは整理されているが、`web/src/data/quizzes.ts` の starter pack と `backend/seeds/quizzes.production.json` の同期は手作業になりやすい

このため、追加するなら「データ lint の重複」ではなく、開発体験と横断整合性を補うスクリプトが優先度高め。

## 課題1: 開発環境の診断スクリプトを作る

### 目的

`scripts/dev_doctor.py` を作り、開発に必要なコマンドやファイルが揃っているかを一括確認できるようにする。

### あると便利な理由

- このリポジトリは `web`、`admin-web`、`backend`、`mobile` の複数ランタイムをまたぐ
- `mobile/README.md` にある通り、Flutter ツールが未導入の環境もある
- `create_backend_env.py` はあるが、全体の前提条件チェックまではしていない

### 仕様の例

- 確認対象
  - `node`
  - `npm`
  - `go`
  - `python3`
  - `docker`
  - `migrate`
  - `flutter`（任意扱いでもよい）
- ファイル確認
  - `backend/.env`
  - `backend/seeds/quizzes.production.json`
  - `docs/api/public-quiz-api.yaml`
- 結果を `OK / WARN / FAIL` で表示する
- `FAIL` が1件でもあれば終了コード `1`

### 学べること

- `subprocess.run`
- `shutil.which`
- `pathlib.Path`
- 終了コード設計

### 完了条件

- `python3 scripts/dev_doctor.py` で一括診断できる
- 足りないコマンド名やファイルパスが具体的に表示される

## 課題2: リポジトリ横断の verify スクリプトを作る

### 目的

ローカルで CI 相当の最低限チェックをまとめて回す `scripts/verify_all.py` を作る。

### あると便利な理由

- 現在のチェックは GitHub Actions に分散している
  - `frontend.yml`
  - `backend.yml`
  - `quiz-data.yml`
  - `openapi.yml`
- ローカルでは実行順やコマンドを毎回思い出す必要がある

### 仕様の例

- 実行対象
  - `admin-web`: `npm run lint` / `npm run build`
  - `web`: `npm run lint` / `npm run build`
  - `backend`: `gofmt -l .` / `go vet ./...` / `go build ./...` / `go test ./... -count=1`
  - quiz data: `python3 scripts/lint_quizzes.py ...` / `python3 scripts/check_quiz_drift.py ...`
  - openapi: `npx --yes @redocly/cli lint docs/api/public-quiz-api.yaml`
- `--only backend` や `--only frontend` のような部分実行オプションを付ける
- 失敗したコマンドを最後に一覧表示する

### 学べること

- 複数コマンドの逐次実行
- ログ整形
- 失敗時の継続可否判断
- CLI 引数設計

### 完了条件

- 1 コマンドでローカル検証をまとめて実行できる
- どのサブプロジェクトで落ちたかがすぐ分かる

## 課題3: starter pack 生成スクリプトを作る

### 目的

`backend/seeds/quizzes.production.json` から `web/` 用の starter pack を生成する `scripts/export_starter_quizzes.py` を作る。

### あると便利な理由

- `web/README.md` では、公開 API 未統合の間は `web/src/data/quizzes.ts` の starter pack を使う構成になっている
- ただし production seed とは別管理なので、内容がずれる可能性がある
- 既存の `diff_quiz_data.py` は候補プールと production seed しか見ていない

### 仕様の例

- 入力
  - `backend/seeds/quizzes.production.json`
- 出力
  - `web/src/data/quizzes.generated.ts`
- 出力内容
  - `Quiz` 型に合う配列を `export const STARTER_QUIZZES = ...` で出力
- 任意で `--limit 20` や `--section React` を付けられるようにする
- 既存の `web/src/data/quizzes.ts` を薄い再エクスポートに寄せてもよい

### 学べること

- JSON 読み込みと整形
- TypeScript ファイルの自動生成
- 「手入力をやめて正本から生成する」設計

### 完了条件

- seed JSON を更新後、1 コマンドで starter pack を再生成できる
- 生成物で `web` の build が通る

## 課題4: 公開 API のスモークスクリプトを作る

### 目的

`scripts/smoke_public_api.py` を作り、バックエンド起動後に公開 API の基本応答を機械的に確認できるようにする。

### あると便利な理由

- `backend/main.go` には `/healthz`、`/v1/quizzes`、`/v1/quizzes/{id}`、`/v1/sections` がある
- `docs/api/public-quiz-api.yaml` は存在するが、「実際に起動中 API が最低限返るか」の簡易チェックがない
- `web` と `mobile` はどちらも公開 API に依存するため、ここが壊れると横断的に影響する

### 仕様の例

- 確認対象
  - `GET /healthz`
  - `GET /v1/quizzes`
  - `GET /v1/sections`
  - `GET /v1/quizzes/{id}`（最初の1件を使う）
- 検証内容
  - ステータスコード
  - JSON であること
  - 必須キーがあること
- `--base-url http://localhost:8080` を受け付ける

### 学べること

- HTTP クライアント
- レスポンス検証
- スモークテストの粒度

### 完了条件

- バックエンド起動中に 1 コマンドで API の基本動作を確認できる
- 失敗時に「どのエンドポイントの何が不正か」を表示できる

## 着手順のおすすめ

1. `dev_doctor.py`
2. `verify_all.py`
3. `smoke_public_api.py`
4. `export_starter_quizzes.py`

この順番にすると、最初に開発基盤を整えてから、API とデータ生成に進める。

## どれを最優先にするか

最優先は `verify_all.py`。

理由は単純で、このリポジトリは構成要素が多いのに、ローカルで全体の健全性を確認する入口がまだないから。学習効果も高く、完成すると以後の作業全体が楽になる。
