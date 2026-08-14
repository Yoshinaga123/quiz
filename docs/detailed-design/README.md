# 詳細設計（Detailed design）

内部の作り方（関数分割、SQL、シーケンス、画面内状態）を置く場所。

[Zod](https://github.com/colinhacks/zod) の `packages/docs/content` に合わせ、このフォルダだけを詳細設計の正本にする。目次は [`meta.json`](./meta.json)。ページ名は kebab-case。

## 他ドキュメントとの境界

| 層 | 場所 | 書くこと |
|---|---|---|
| 要件 | [`../../quiz.md`](../../quiz.md) | 何をしたいか |
| 基本設計（外の契約） | [`../architecture/`](../architecture/)、[`../api/`](../api/)、[`../adr/`](../adr/) | 構成、OpenAPI、なぜそう決めたか |
| **詳細設計（中の組み立て）** | **このフォルダ** | ハンドラ、SQL、Zod refine、画面内フロー |
| 実装 | `backend/`、`web/`、`admin-web/`、`mobile/` | コード |

OpenAPI（[`../api/public-quiz-api.yaml`](../api/public-quiz-api.yaml)）は基本設計。ここには書かない。

## ディレクトリ

Zod の `content/packages/*` と同様、実装パッケージごとに分ける。

```text
docs/detailed-design/
├── README.md          ← このファイル（入口）
├── meta.json          ← 目次（追加したら必ず更新）
├── backend/           ← Go API・DB アクセス
├── web/               ← ユーザー向け Web
├── admin-web/         ← 管理画面
└── mobile/            ← Flutter
```

## 書き方

- ファイル名は **kebab-case 英語**（例: `public-quiz-handlers.md`）。Zod の `error-customization.mdx` と同じ。
- 1 ファイル 1 関心事。巨大な「詳細設計書.docx 相当」を 1 本にまとめない。
- 先頭に、参照する基本設計（ADR / OpenAPI / architecture）へのリンクを置く。
- 実装と食い違ったら **コードかこのフォルダを直す**。公開 JSON なら OpenAPI・fixtures・Zod・Go・テストも同じ PR（[`web/public-contract.md`](./web/public-contract.md)）。
- 未着手のページは作らない。書くときに追加し、`meta.json` の `pages` に載せる。

## 含めるもの / 含めないもの

含める:

- 処理シーケンス、擬似コード、関数・モジュールの責務
- SQL / トランザクション境界
- Zod の `.refine` など、OpenAPI に書けない業務ルール
- 画面内の状態遷移（どの hook が何を持つか）

含めない:

- URL 契約そのもの → `docs/api/`
- システム全体図 → `docs/architecture/`
- 意思決定の経緯 → `docs/adr/`
- 診断手順・学習メモ → `docs/security-tools/` など
