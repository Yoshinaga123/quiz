# Socrates Quiz

高難度 IT クイズアプリ。ユーザー向け Web / Flutter、管理画面、Go API で構成する。

本番の公開ホストは [`https://socrates-quiz.jp`](https://socrates-quiz.jp)（HTTPS 443）。開発時の API は `http://localhost:8082`。

本番の起動手順は [`docs/deploy-lightsail.md`](docs/deploy-lightsail.md)（[ADR 0015](docs/adr/0015-lightsail-production.md)）。

| パッケージ | 役割 | 認証 |
| --- | --- | --- |
| [`packages/web/`](packages/web/) | 解答 UI・端末内履歴 | なし |
| [`packages/admin-web/`](packages/admin-web/) | 問題 CRUD・mock Push | JWT Bearer |
| [`packages/mobile/`](packages/mobile/) | ネイティブ解答・mock 通知 | なし（公開 API） |
| [`packages/backend/`](packages/backend/) | Public `/v1/*` + Admin `/api/admin/*` | 公開なし / 管理 JWT |

クイズ本文の正本は PostgreSQL `quizzes`。候補プールは `packages/admin-web/src/data/quizzes.json`、本番シードは `packages/backend/seeds/quizzes.production.json`。

## 必要なもの

- Node.js 22+
- Go 1.26+
- Docker（PostgreSQL + API）
- Flutter 3.3+（モバイルのみ）

## クイックスタート

```bash
cd packages/backend
cp .env.example .env
docker compose up --build
```

| サービス | URL |
| --- | --- |
| API | http://localhost:8082 |
| ヘルス | http://localhost:8082/healthz |
| 管理画面 | ルートで `npm i` のあと `cd packages/admin-web && npm run dev`（既定 5173） |
| ユーザー Web | ルートで `npm i` のあと `cd packages/web && npm run dev`（5174） |

公開 API 仕様: [`docs/api/public-quiz-api.yaml`](docs/api/public-quiz-api.yaml)  
ドキュメント目次: [`docs/INDEX.md`](docs/INDEX.md)

## テスト

ルート（Node 22、[`.nvmrc`](.nvmrc)）:

```bash
npm install
npm test
npm run lint
```

個別:

```bash
python3 scripts/check_public_contract.py
python3 scripts/check_repo_hygiene.py
cd packages/web && npm test
cd packages/backend && go test ./...
cd packages/admin-web && npm test
cd packages/mobile && flutter test
```

試し書きは `npm run play`（`src/` には残さない）。エージェント向け手順は [`AGENTS.md`](AGENTS.md)。

## リポジトリの分け方

| パス | 位置づけ |
| --- | --- |
| [`packages/`](packages/) | **商品**（web / admin-web / backend / mobile）と **実行速度計測**（[`bench/`](packages/bench/)） |
| [`docs/`](docs/INDEX.md) | **説明書**（OpenAPI / 詳細設計 / ADR / lint）。商品フォルダには置かない |
| `scratch/`（gitignore） | **kB 計測**（手元の `input.ts`。運用経緯は [Issue #19](https://github.com/Yoshinaga123/quiz/issues/19)） |
| `samples/`（gitignore） | **学習**（手元の参考クローン。公開ツリーには含めない） |
| [`archive/`](archive/README.md) | **学習・診断の隔離方針** |

貢献手順は [`CONTRIBUTING.md`](CONTRIBUTING.md)。行動規範は [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)。脆弱性報告は [`SECURITY.md`](SECURITY.md)。ライセンスは MIT（[`LICENSE`](LICENSE)）。
