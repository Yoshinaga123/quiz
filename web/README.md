# Quiz Web

ユーザー向け IT クイズ Web アプリ（`quiz.md` で定義された Web 向けクイズアプリ）。

`admin-web/` と同じく React 19 + Vite 7 + TypeScript 5.9 + Tailwind CSS v4 + zod ^4 で構成し、規約・ESLint 設定は `admin-web/` と揃えている。

## 役割

- IT 系の英文読解・コードの意味を問うクイズの **解答 UI** を提供する
- セッションごとの正答数・正答率・履歴を **ローカル** に保存する
- 管理画面 (`admin-web/`) は CRUD のみ、こちらは回答体験のみ、と責務を完全分離する

## 現状（バックエンド未統合）

`backend/main.go` は `GET /v1/quizzes` を提供しているが、`web/` はまだ統合していない。
現在は `src/data/quizzes.ts` に同梱した **starter pack（インライン定義）** を使って単独で動作する。

API 統合の際は以下が必要になる。

1. `src/hooks/useQuizCatalog.ts` を非同期対応に書き換える（現状は同期 `Quiz[]` 返し。`fetchQuizzes()` は `Promise<Quiz[]>` のため、`useEffect + state` か SWR 等への変更が必要）
2. `src/api/quiz.ts`（実装済み）の `fetchQuizzes()` を hook から呼び出す
3. ローディング・エラー状態を呼び出し元の画面に伝播させる
4. `STARTER_QUIZZES` をフォールバックとして残すか削除するかを決める

の順で移行できるよう、データ取得は単一エントリ `loadQuizzes()` に閉じてある。

## スクリプト

```bash
npm install
npm run dev      # http://localhost:5174
npm run build
npm run lint
```

## ディレクトリ構造

```
src/
  pages/         # ルート単位の画面
  components/    # 1 ファイル 1 コンポーネント
  layouts/       # 共通レイアウト
  contexts/      # Context（履歴の保持）
  hooks/         # カスタムフック
  lib/           # 純粋関数ユーティリティ（DOM/IO 非依存）
  schemas/       # zod スキーマ
  types/         # 型定義
  data/          # starter pack のクイズデータ
```

## 履歴データ

- `localStorage` キー: `quzzes:history:v1`
- 構造は `src/schemas/history.ts` の `historyRecordSchema` で zod 検証
- 破損データは黙って初期化せず、起動時にコンソールに警告を出して空履歴で再開する

## アーキテクチャ判断

- 採点と履歴は**クライアントローカルで完結**させ、API 設計が固まる前に UX を回せるようにする
- 状態管理は React の `useState` / Context のみ（`docs/implement-policy.md` 実装ポリシー4 準拠）
- ルーティングは `react-router-dom` v7 の `BrowserRouter`（History API ベース、`docs/implement-policy.md` 実装ポリシー5 準拠）

## 関連

- 要件定義: `../quiz.md`
- 実装ポリシー: `../docs/implement-policy.md`
- データワークフロー: `../docs/quiz-data-workflow.md`
- 管理画面: `../admin-web/`
- モバイル: `../mobile/`
- バックエンド: `../backend/`
