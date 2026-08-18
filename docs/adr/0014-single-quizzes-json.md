# ADR 0014: 問題ファイルは `quizzes.json` 一本、公開選別は `published`

- Status: Accepted
- Date: 2026-08-17
- Deciders: Quiz App Team
- Related: [`../quiz-data-workflow.md`](../quiz-data-workflow.md)

## Context

候補プール（`packages/admin-web/src/data/quizzes.json`）と本番シード（`packages/backend/seeds/quizzes.production.json`）を分けていた。同じ問題を二箇所で直し、差分スクリプトが必要だった。

公開 API の `publicQuiz` に管理用フィールドを出さない制約はそのまま残す。

## Decision

Git 上の問題ファイルは **`packages/admin-web/src/data/quizzes.json` だけ** にする。

- 採用する問題は `published: true`
- 下書きは `published: false` のまま同じファイルに残す
- シード SQL / DB 同期の入力は `published: true` だけ
- `published` は seed / 管理プレビュー用。`publicQuiz` には出さない
- DB の `status` と `push_enabled` は従来どおりシードで上書きしない

`quizzes.production.json` は置かない。

## Consequences

### Positive

- 採用時にファイルをコピーしなくてよい
- lint / drift / プレビューの対象が一本になる

### Negative / follow-up

- シード対象を空にすると replace 同期で DB が空になる
- バックエンドは `packages/admin-web` の JSON を読む。Docker では `QUIZ_SEED_PATH` でマウントする
