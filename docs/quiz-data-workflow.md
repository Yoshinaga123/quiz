# クイズデータワークフロー

## 概要

クイズの問題データは「候補プール」と「本番データ」の 2 層で管理する。

| 層 | 保管場所 | 役割 |
|---|---|---|
| 候補プール | `admin-web/src/data/quizzes.json` | プレビュー用の問題文ストック。下書き・レビュー段階の問題をすべて含む |
| 本番データ | PostgreSQL `quizzes` テーブル | ユーザーに配信する選出済みの問題。管理画面から登録・編集する |

## データの流れ

```
quizzes.json（候補プール）
    │
    │  管理者がプレビューで内容を確認
    │  JsonQuizPreviewSection で表示
    │
    ▼
管理画面で採用を判断
    │
    │  管理画面のクイズ作成フォームから DB に登録
    │
    ▼
PostgreSQL quizzes テーブル（本番データ）
    │
    │  API 経由で配信
    │
    ▼
ユーザー向けアプリ
```

## quizzes.json の位置づけ

- 問題文の **下書き・候補集** である
- すべての問題が本番に採用されるわけではない
- MDN Web Docs などの出典に基づいて作成し、正確性を確認した上でプールに追加する
- ビルド時にフロントエンドに埋め込まれるが、本番配信には使用しない

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
      "source": "出典 URL"
    }
  ]
}
```

## PostgreSQL quizzes テーブルの位置づけ

- **本番環境の Single Source of Truth（正）** である
- 管理画面の CRUD 操作はすべてこのテーブルに対して行う
- `status`（published / unpublished）で公開状態を制御する
- `push_enabled` で PUSH 通知配信の対象を制御する

## 関連するコンポーネント

| ファイル | 役割 |
|---|---|
| `admin-web/src/data/quizzes.json` | 候補プールの実体 |
| `admin-web/src/types/quiz.ts` | JSON 用の型定義 |
| `admin-web/src/utils/quizUtils.ts` | JSON からの読み取り・検索・統計計算 |
| `admin-web/src/components/JsonQuizPreviewSection.tsx` | JSON プレビュー表示 |
| `admin-web/src/types/admin.ts` | DB 連携用の型定義 |
| `admin-web/src/api/admin.ts` | DB 連携用の API クライアント |

## 運用ルール

1. 新しい問題を思いついたら、まず `quizzes.json` に追加する
2. 管理画面のプレビュー機能で問題文・選択肢・解説の品質を確認する
3. 採用する問題を管理画面のクイズ作成フォームから DB に登録する
4. DB 登録後、`status` を `published` に切り替えて配信対象にする
5. `quizzes.json` の問題は削除せず、候補プールとして残す
