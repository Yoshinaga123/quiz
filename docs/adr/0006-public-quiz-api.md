# ADR 0006: Public Quiz API の仕様分離

- Status: Accepted
- Date: 2026-04-21
- Deciders: Quiz App Team
- Related: ADR 0001, ADR 0002, ADR 0005

## Context

これまでバックエンド API は `admin-web` の管理用エンドポイントが中心だった。
ADR 0005 で `web/` と `mobile/` のユーザー向けクライアントが正式に位置付けられたため、
両者から呼ばれる **公開 API の境界** を決める必要がある。

要点:

- 管理 API と公開 API は **認証要件・キャッシュ要件・SLA・リスク** が異なる。
- 管理 API はゼロまたは少数の管理者のみ呼ぶ書き込み中心、公開 API は大量の匿名ユーザーが呼ぶ読み取り中心。
- レスポンス形状は `web/src/schemas/quiz.ts` の Zod スキーマと **逐語的に一致** させる必要がある
  （docs/implement-policy.md「外部入力の検証」原則）。

## Decision

公開 API を **`/v1/...` プレフィックス + 専用ハンドラ群** として論理的に分離し、
仕様を `docs/api/public-quiz-api.yaml`（OpenAPI 3.1）に集約する。

主要原則:

1. **読み取り中心**: 公開エンドポイントは原則 `GET`。書き込みは匿名集計用 `POST /v1/attempts` のみ許可。
2. **status フィルタ**: 公開 API は `status = published` のクイズのみを返す。`unpublished` は管理 API でしか参照できない。
3. **キャッシュ可能性**: GET は HTTP キャッシュヘッダ（ETag / Cache-Control）を将来付与する前提で設計し、
   レスポンスはユーザーごとに変化しないこと。
4. **エラー形式の統一**: `{ code, message, details? }` 構造で 400 / 404 / 500 を返す。
5. **互換性**: パスに `/v1/` を含め、破壊的変更時は `/v2/` を新設する。

## Consequences

### Positive

- フロントエンド・モバイルの **生成型クライアント（OpenAPI から）** に将来移行しやすい。
- 公開 API の挙動を `docs/api/public-quiz-api.yaml` 一箇所で議論・レビューできる。
- 管理 API と公開 API のミドルウェア（認証、レート制限、CORS）を独立に組める。
- ADR 0008 の匿名集計フローも同じ仕様書内で表現できる。

### Negative

- 当面は OpenAPI と Go ハンドラ実装の二重管理になる。差分は CI で監視する（D 系ワークフローで `openapi-lint` を実装）。
- 既存の管理 API と URL 設計が分かれるため、Go 側で muxer / middleware の整理が必要になる。

## Migration Plan

1. `docs/api/public-quiz-api.yaml` をレビューして合意。 ✅ 初版レビュー済み。
2. `backend/main.go` に `/v1/quizzes`, `/v1/quizzes/{id}`, `/v1/sections`, `/healthz` を実装し、
   `status = published` フィルタを適用する。 ✅ 実装済み（`handleListPublicQuizzes` / `handleGetPublicQuiz` / `handleListPublicSections` / `handleHealthz`）。
3. `web/` の `useQuizCatalog` を `fetchQuizzes()` に切り替える（`VITE_API_BASE_URL` がある場合）。⏳ 次イテレーションで対応。
4. `mobile/` の Repository も同 API を参照する Remote DataSource に置き換える。⏳ 次イテレーションで対応。
5. `POST /v1/attempts` は ADR 0008 と合わせて後続イテレーションで実装する。⏳ 未着手。

## Alternatives Considered

- **GraphQL**: クエリの自由度は魅力だが、本アプリのアクセスパターンは固定的で、
  バックエンドの実装コストがメリットを上回らない。
- **Firebase Firestore 直結**: コスト試算と運用主権、データの可搬性の観点で `Go + PostgreSQL` を維持。
