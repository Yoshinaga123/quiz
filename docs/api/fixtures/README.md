# Public API fixtures

公開契約（OpenAPI `Quiz` など）の **実行時に突き合わせる例**。

shape を変えたら、この JSON・`public-quiz-api.yaml`・Zod・Go `publicQuiz`・詳細設計・テストを **同じ PR** で直す。

| ファイル | 対象スキーマ | 用途 |
| --- | --- | --- |
| `quiz.json` | `Quiz` | 成功例 |
| `quiz-invalid-answer-index.json` | `Quiz` + `.refine` | 正解番号が範囲外（失敗） |
| `quiz-list.json` | `QuizListResponse` | `GET /v1/quizzes` |
| `sections.json` | セクション一覧 | `GET /v1/sections` |
| `error.json` | `Error` | 公開エラー `{ code, message }` |
| `push-feed.json` | `PushFeed` | `GET /v1/push/feed` |

`quiz-list.json` の先頭要素は `quiz.json` と同一であること（`scripts/check_public_contract.py` が検証する）。
