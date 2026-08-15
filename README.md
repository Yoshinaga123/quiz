# Socrates Quiz

高難度 IT クイズアプリ。ユーザー向け Web / Flutter、管理画面、Go API で構成する。

本番の公開ホストは [`https://socrates-quiz.jp`](https://socrates-quiz.jp)（HTTPS 443）。開発時の API は `http://localhost:8082`。

| パッケージ | 役割 | 認証 |
| --- | --- | --- |
| [`web/`](web/) | 解答 UI・端末内履歴 | なし |
| [`admin-web/`](admin-web/) | 問題 CRUD・mock Push | JWT Bearer |
| [`mobile/`](mobile/) | ネイティブ解答・mock 通知 | なし（公開 API） |
| [`backend/`](backend/) | Public `/v1/*` + Admin `/api/admin/*` | 公開なし / 管理 JWT |

クイズ本文の正本は PostgreSQL `quizzes`。候補プールは `admin-web/src/data/quizzes.json`、本番シードは `backend/seeds/quizzes.production.json`。

## 必要なもの

- Node.js 22+
- Go 1.26+
- Docker（PostgreSQL + API）
- Flutter 3.3+（モバイルのみ）

## クイックスタート

```bash
cd backend
cp .env.example .env
docker compose up --build
```

| サービス | URL |
| --- | --- |
| API | http://localhost:8082 |
| ヘルス | http://localhost:8082/healthz |
| 管理画面 | `cd admin-web && npm install && npm run dev`（既定 5173） |
| ユーザー Web | `cd web && npm install && npm run dev`（5174） |

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
cd web && npm test
cd backend && go test ./...
cd admin-web && npm test
cd mobile && flutter test
```

試し書きは `npm run play`（`src/` には残さない）。エージェント向け手順は [`AGENTS.md`](AGENTS.md)。

## リポジトリの分け方

| パス | 位置づけ |
| --- | --- |
| `web/` `admin-web/` `mobile/` `backend/` `docs/architecture/` `docs/api/` `docs/adr/` `docs/detailed-design/` | **プロダクト** |
| [`samples/`](samples/) [`archive/`](archive/README.md) `docs/security-tools/` など | **学習・診断アーカイブ**（実行時に不要） |

貢献手順は [`CONTRIBUTING.md`](CONTRIBUTING.md)。行動規範は [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)。脆弱性報告は [`SECURITY.md`](SECURITY.md)。ライセンスは MIT（[`LICENSE`](LICENSE)）。
