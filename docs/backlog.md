# バックログ

未着手・進行中の改善タスクを記録する。
完了したらステータスを更新するか、別セクションへ移す。

## オープン

### TASK-001: クイズデータの出典品質を改善する

- **由来**: システムレビュー指摘 #6
- **優先度**: P1（正誤判定の根拠に直結する問題を最優先）
- **参照**: [`quizzes-quality-review.md`](./quizzes-quality-review.md)

**背景**

`packages/admin-web/src/data/quizzes.json`（586 問）の構造は lint 通過済みだが、出典の品質が要件（高品質ドキュメント由来・正確・最新）を満たしていない。

**現状の課題**

| 種別 | 件数（概算） | 内容 |
| --- | --- | --- |
| 曖昧な `source` ラベル | 491 | `sourceLinks.ts` 未マップ、検索フォールバック依存 |
| リポジトリ内ファイル参照 | 126 | `packages/backend/main.go` 等を出典にしている |
| 直接 URL | 82 | 比較的妥当 |
| 正誤根拠が崩れている問題 | 1+ | 例: id 225（Googlebot 50MB 変更の検証不可） |

**やること**

1. P1 問題（出典と主張の不一致）を修正する
2. リポジトリ内ファイル参照を公式ドキュメント URL に置き換える（または仕様 URL を併記する）
3. 時事性のある主張は出典 URL で固定できる形に直す
4. `sourceLinks.ts` のマップを拡充し、曖昧ラベルを減らす
5. 修正後 `python3 scripts/lint_quizzes.py` で再検証する

**完了条件**

- P1 問題が解消されている
- 曖昧 `source` の比率が下がっている（目標はチーム合意で設定）
- 新規追加問題も URL または明示マップ付きラベルに統一されている

---

### TASK-002: テスト基盤を実態に合わせて整備する

- **由来**: システムレビュー指摘 #7
- **優先度**: P1（backend） / P2（web）
- **参照**: [`packages/web/tests/README.md`](../web/tests/README.md), [`.github/workflows/backend.yml`](../.github/workflows/backend.yml)

**背景**

CI はテストを実行しているが、backend に `*_test.go` がなく web は Vitest 未導入のため、実質的な自動テストがほぼない。lint 方針（`packages/admin-web/docs/linting.md`）と実態にギャップがある。

**やること**

#### backend（P1）

1. ハンドラまたは純粋関数のユニットテストを追加する（優先: 公開 API、ログイン、payload 正規化）
2. DB 依存テストは `httptest` + テスト用 DB、または repository 層分割後に導入する
3. CI の `go test ./...` が意味のある失敗検知をする状態にする

#### web（P2）

1. `packages/web/package.json` に Vitest 依存を追加する（手順は `packages/web/tests/README.md`）
2. 既存雛形（`quizUtils`, `historyStorage`, `client`, `schemas/quiz`）を実行可能にする
3. `npm run test` を CI（`frontend.yml`）に組み込む

#### mobile（P3・任意）

1. 既存 `packages/mobile/test/` を CI で回す（Flutter ツールチェーン導入後）

**完了条件**

- backend: 主要 API 境界に最低 1 本以上のテストがあり、CI で green
- web: Vitest がローカル・CI で実行され、雛形テストが pass
- テスト追加方針が ADR または README に 1 段落で記載されている

---

### TASK-003: Push 通知モック（手動送信 + 配信履歴 + ローカル通知）

- **由来**: システムレビュー指摘 #10 / ADR 0007 Phase A
- **優先度**: P2
- **参照**: [`adr/0007-push-notification-delivery.md`](./adr/0007-push-notification-delivery.md)
- **スコープ**: Firebase / FCM / cron **は含めない**。配信フローの動作確認まで。
- **決定事項（2026-05-25）**: mobile の受信経路は **案 A** — 公開 API `GET /v1/push/feed` で最新 mock 配信1件を取得する

**ゴール**

管理画面から「テスト送信」を押す → backend がクイズを1問選び配信履歴を記録 → mobile がローカル通知で表示、という一連の流れをモックで通す。

**非ゴール（Phase B 以降）**

- 本物の FCM / APNs 送信
- `device_tokens` 登録 API と実トークン管理
- cron による毎日 JST 09:00 自動送信
- Web Push (VAPID)

---

#### Phase 0: 設計・合意

- [ ] **TODO-003-01** ADR 0007 に「Phase A: Mock」を追記する（本 ADR の Decision は維持、実装段階だけ分離）
- [ ] **TODO-003-02** モック API の契約を決める
  - 手動送信: `POST /api/admin/push/dispatch`（JWT 必須）
  - 履歴一覧: `GET /api/admin/push/deliveries`（JWT 必須、ページネーション可）
  - **公開 feed（案 A・確定）**: `GET /v1/push/feed`（認証なし、最新 mock 配信1件）
  - dispatch レスポンス例: `{ deliveryId, quizId, title, channel: "mock", targetCount: 0, status: "mock_sent" }`
  - feed レスポンス例: `{ deliveryId, quizId, title, body, sentAt, channel: "mock" }`（配信なし時は `404`）
- [ ] **TODO-003-03** クイズ選定ルールを ADR 0007 に合わせて固定する
  - 条件: `status = published` AND `push_enabled = true`
  - 直近 N 日（初期値 7 日）の `push_deliveries` に載った `quiz_id` は除外
  - 候補が0件のときは `409` または `422` で明示エラー
- [ ] **TODO-003-04** 通知ペイロード形状を決める（mobile ローカル通知用）
  - `title`, `body`, `quizId`（タップ時ディープリンク用）

---

#### Phase 1: backend — DB

- [x] **TODO-003-05** migration `015_create_push_deliveries.up.sql` を追加する

```sql
CREATE TABLE push_deliveries (
    id           BIGSERIAL PRIMARY KEY,
    quiz_id      BIGINT NOT NULL REFERENCES quizzes(id),
    channel      VARCHAR(20) NOT NULL DEFAULT 'mock',  -- mock | fcm (将来)
    target_count INT NOT NULL DEFAULT 0,
    status       VARCHAR(20) NOT NULL,                 -- mock_sent | failed (将来)
    error_detail TEXT,
    sent_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_push_deliveries_sent_at ON push_deliveries (sent_at DESC);
CREATE INDEX idx_push_deliveries_quiz_id ON push_deliveries (quiz_id);
```

- [x] **TODO-003-06** `down.sql` を追加する
- [x] **TODO-003-07** [`docs/architecture/data-model.md`](./architecture/data-model.md) に `push_deliveries` を追記する

---

#### Phase 2: backend — ドメインロジック

- [x] **TODO-003-08** クイズ選定関数を `main.go` 内に追加する（将来パッケージ分割は別タスク）
  - 入力: `excludeDays`（env または定数、初期 7）
  - 出力: 選ばれた `quiz` 1 件
  - 候補0件・DB エラーを区別する
- [x] **TODO-003-09** モック送信関数を追加する
  - FCM クライアントは呼ばない
  - `push_deliveries` に INSERT（`channel=mock`, `target_count=0`, `status=mock_sent`）
  - 構造化ログに `quiz_id`, `delivery_id` を出力する
- [x] **TODO-003-10** 排他制御を検討する
  - 同時に2回 dispatch された場合: `sync.Mutex` または DB トランザクションで二重選定を防ぐ
  - Seed 同期の `seedMu` と同様、競合時は `409` を返す方針でよい

---

#### Phase 3: backend — HTTP API

- [x] **TODO-003-11** `POST /api/admin/push/dispatch` を `requireAuth` 配下に追加する
  - 成功: `201` + 配信結果 JSON
  - 候補クイズなし: `422` + `{ error, code: "no_push_candidates" }`
  - 同時実行競合: `409`
- [x] **TODO-003-11a** `GET /v1/push/feed` を Public API に追加する（**案 A・確定**）
  - 認証なし
  - `push_deliveries` から `channel = 'mock'` AND `status = 'mock_sent'` の最新1件を返す
  - `quizzes` と JOIN して `title` / 通知 `body`（例: 問題文の先頭 N 文字）を含める
  - 該当なし: `404` + public error format（`code: push_feed_not_found`）
- [x] **TODO-003-12** `GET /api/admin/push/deliveries` を追加する
  - クエリ: `page`, `per_page`（既存 admin 一覧と同じ上限）
  - 返却: 配信履歴 + クイズ `title`（JOIN または二次取得）
- [x] **TODO-003-13** エラー形式を既存 admin API（`errorResponse`）に揃える
- [x] **TODO-003-14** ルーティング一覧を [`docs/architecture/backend-flow.md`](./architecture/backend-flow.md) に追記する
- [x] **TODO-003-14a** [`docs/api/public-quiz-api.yaml`](../docs/api/public-quiz-api.yaml) に `/v1/push/feed` を追記する（OpenAPI ドラフト）

---

#### Phase 4: admin-web — 管理 UI

- [x] **TODO-003-15** `packages/admin-web/src/schemas/push.ts` に zod スキーマを追加する
  - `pushDispatchResponseSchema`
  - `pushDeliveryListResponseSchema`
- [x] **TODO-003-16** `packages/admin-web/src/api/admin.ts` に API 関数を追加する
  - `dispatchMockPush(): Promise<PushDispatchResponse>`
  - `fetchPushDeliveries(params): Promise<PushDeliveryListResponse>`
- [x] **TODO-003-17** クイズ一覧画面または専用セクションに UI を追加する
  - 「モック Push 送信」ボタン（確認ダイアログ付き）
  - 成功時: 選ばれたクイズ ID / タイトル / 送信時刻を flash 表示
  - 失敗時: `no_push_candidates` をユーザー向け文言に変換
- [x] **TODO-003-18** 配信履歴テーブル（直近10件程度）を管理画面に表示する
- [x] **TODO-003-19** 既存 `PushBadge`（クイズごとの ON/OFF）との関係を UI 上で説明する
  - 「ON のクイズだけが送信候補」である旨の短いヘルプテキスト

---

#### Phase 5: mobile — ローカル通知

- [x] **TODO-003-20** `pubspec.yaml` に依存を追加する
  - `flutter_local_notifications`（必須）
  - Android: 初期化用の icon 設定
  - iOS: 通知権限リクエスト（`Info.plist` の説明文）
- [x] **TODO-003-21** 通知サービスを presentation 外に切り出す（ADR 0009 準拠）
  - 例: `lib/layers/data/service/local_notification_service.dart`
  - 初期化: `main.dart` または `AppRoot` 起動時
- [x] **TODO-003-22** mobile の受信経路 — **案 A で確定**
  - backend: `GET /v1/push/feed`（認証なし・最新 mock 配信1件）
  - mobile: アプリ起動時 + フォアグラウンド復帰時 + 「最新を確認」ボタンで feed をポーリング
  - 取得した `deliveryId` が前回表示済みと異なればローカル通知を出す（重複通知防止）
- [x] **TODO-003-22a** `QuizApiClient` に `fetchPushFeed()` を追加する
  - DTO: `PushFeedDto`（`deliveryId`, `quizId`, `title`, `body`, `sentAt`, `channel`）
  - 404 は「未配信」として正常系（通知しない）
- [x] **TODO-003-22b** `PushFeedPoller`（または Riverpod `Notifier`）を追加する
  - 最後に通知した `deliveryId` を `shared_preferences` に保存
  - 新規配信検知時に `LocalNotificationService.show()` を呼ぶ
- [x] **TODO-003-23** 通知タップ時の遷移を実装する
  - `quizId` を受け取り `QuizDetailsPage` へ遷移（go_router 未導入なら `Navigator.push`）
- [x] **TODO-003-24** Android / iOS の権限ダイアログと拒否時 UXを実装する
- [x] **TODO-003-25** [`packages/mobile/README.md`](../packages/mobile/README.md) にモック通知の起動手順を追記する

---

#### Phase 6: テスト・ドキュメント

- [x] **TODO-003-26** backend: クイズ選定ロジックのユニットテスト（DB モック or テスト DB）
- [x] **TODO-003-27** backend: `POST /api/admin/push/dispatch` の httptest（JWT + 201 / 422）
- [x] **TODO-003-28** admin-web: API レスポンス zod スキーマのテスト（Vitest 導入後でも可）
- [ ] **TODO-003-29** mobile: `LocalNotificationService` の初期化テスト（可能な範囲）
- [x] **TODO-003-30** [`docs/counter-api.md`](./counter-api.md) ではなく push 用に [`docs/push-notification-mock.md`](./push-notification-mock.md) を新規作成する
  - 手動確認手順（admin 送信 → mobile 表示）
  - Phase B への差し替えポイント（FCM クライアント注入）
- [x] **TODO-003-31** [`docs/INDEX.md`](./INDEX.md) に上記ドキュメントを追加する

---

#### 完了条件

- [ ] 管理画面からモック送信でき、DB の `push_deliveries` に記録される
- [ ] `push_enabled = false` のクイズだけでは送信できない（422）
- [ ] mobile でローカル通知が表示され、タップで該当クイズ詳細に遷移できる
- [ ] Firebase / FCM の設定なしでローカル開発完結する
- [ ] 実装手順が `docs/push-notification-mock.md` に記載されている

---

#### 実装順序（推奨）

```
Phase 0（合意済み: 案 A） → Phase 1（DB） → Phase 2–3（backend API + /v1/push/feed）
    → Phase 4（admin ボタン） → Phase 5（mobile feed ポーリング + ローカル通知） → Phase 6（テスト・docs）
```

#### 手動確認フロー（案 A）

1. admin-web で対象クイズの Push を ON、`published` にする
2. 「モック Push 送信」を押す → `push_deliveries` に1行追加
3. mobile を起動（または「最新を確認」）→ `GET /v1/push/feed` → ローカル通知表示
4. 通知タップ → 該当クイズ詳細画面へ遷移

---

### TASK-004: Zod Mini への移行（任意・先送り）

- **由来**: Zod 公式が Mini を「バンドル制約が異常に厳しいとき」向けと位置づけていること。低速回線向けの超軽量化の検討。
- **優先度**: P3（マストではない。公式も多数派には classic `zod` を推奨）
- **状態**: 先送り。いまは対応しない。
- **参照**: [zod.dev/packages/mini](https://zod.dev/packages/mini)、[ADR 0002](./adr/0002-frontend-architecture-spa.md)（先に測る）、[Issue #19](https://github.com/Yoshinaga123/quiz/issues/19)（測る入口は `scratch/input.ts`）

**背景**

`packages/web/` と `packages/admin-web/` は classic `zod`（メソッド API）。Mini は関数 API で tree-shake しやすく、既定 locale も載せない。低速モバイル回線では魅力がある。

ただし本番バンドルは Vite 7 + Rollup であり、esbuild の locale 残留問題は本番に当てはまらない。React / react-router / Tailwind のほうが Zod より重い。メンテナは大多数のアプリに classic を推奨している。

**やること（着手するとき）**

1. `scratch/input.ts` で classic と Mini の kB を測る
2. 差がユーザー体感に効くと分かってから `packages/web/` / `packages/admin-web/` の schema を Mini API に書き換える
3. 公開 JSON の shape は変えない（OpenAPI / fixtures / `publicQuiz` はそのまま）

**完了条件**

- 計測結果が残っている
- Mini にした場合は成功・失敗の schema テストが両方通る
- 公開契約チェックが green

---

### TASK-005: ESLint から Biome への移行（将来・先送り）

- **由来**: 2026-08-17。人が「将来的には Biome に移行する」と決めた。いま着手しない。
- **優先度**: P3
- **状態**: 先送り。ESLint が正本のまま。
- **参照**: [Zod #3499](https://github.com/colinhacks/zod/pull/3499)、[`docs/linting.md`](./linting.md)、`AGENTS.md`（Do not）

**背景**

Zod は TypeScript ライブラリとして ESLint をやめて Biome にした（移行は楽だった、と PR にある）。quiz の web / admin-web でも、将来は lint と format を Biome に寄せる。

いま移さない理由: Go は `gofmt`、Flutter は `flutter analyze` のまま残る。husky / lint-staged / frontend CI / VS Code 拡張は ESLint で動いている。依存配列は Biome でも足りるが、付け替え自体は公開契約を良くしない。

**やること（着手するとき）**

1. `biome migrate eslint` で設定の下書きを出し、`typescript-eslint` strict / stylistic と `react-hooks` / `react-refresh` の差分を目で見る
2. `eslint-disable` を `biome-ignore` に直し、依存配列の判定差（安定値・意図した余分な依存）を確認する
3. husky、lint-staged、`frontend.yml`、`.vscode` を Biome に切り替え、ESLint 依存を同じ PR で消す
4. Go / Flutter の検査は残す。Biome に一本化しない

**完了条件**

- web / admin-web の lint / format の正本が Biome
- CI と pre-commit が Biome
- `npm run lint` 相当が green
- 公開契約チェックが green

---

### TASK-006: シーケンス図ツールを比較して標準化する

- **由来**: 2026-08-19。設計説明や運用説明のために、シーケンス図の記法とツールを選定したい。
- **優先度**: P3（導入は既存機能と切り離せる）
- **状態**: 先送り。評価のみを行う。
- **対象**: Mermaid, PlantUML, diagrams.net（ブラウザ版）, draw.io（デスクトップ版/旧名）, Lucidchart

**背景**

PR ベースの運用、protected branch、CI/quality checks、認証フローなどを説明するには、シーケンス図が有効である。まずは最低限の可視化のために、無料枠で扱いやすいツールを比較する（diagrams.net は draw.io のブラウザ版）。

**やること**

1. Mermaid を最小構成で試し、Markdown/GitHub への埋め込みのしやすさを比較する
2. PlantUML を試し、テキストベースでの記述や生成のしやすさを評価する
3. diagrams.net（ブラウザ版）を試し、ブラウザでの図作成の手軽さと編集容易性を確認する
4. draw.io（デスクトップ版）を試し、ローカル運用のしやすさを確認する
5. Lucidchart の無料枠と使いやすさを比較し、チーム共有の観点を確認する
6. 評価結果をもとに、リポジトリで標準化する図作成ツールを決める

**比較軸**

- GitHub / Markdown への埋め込みしやすさ
- 料金と無料枠の制約
- 学習コストと書きやすさ
- 図の見た目の完成度
- 共同編集やドキュメント共有のしやすさ
- PR での差分管理しやすさ

**完了条件**

- 5 ツールの評価メモが残っている
- どれが最適かを 1 段落で記載できる
- 次の設計書や ADR で、標準ツールを使って図を埋め込める状態になっている

---

### REJECTED: `import { z } from "zod"` を `import * as z from "zod"` に揃える

- **状態**: 却下（2026-08-15）
- **由来**: Zod 公式の esbuild 向け注意、および [zod#5561](https://github.com/colinhacks/zod/issues/5561) の「`import {z} from "zod"` can exacerbate the issue in some cases」
- **却下理由**: 名指しは esbuild でバンドルする一部のケース。本番は Vite 7 + Rollup。該当しない。メンテナ自身も「一部のケース」と慎重に書いている。

`packages/web/` / `packages/admin-web/` の `import { z } from "zod"` はそのままにする。エージェントはこの書き換えを再提案しない。

事後計測: 手元で `npm run scratch:measure`（`scratch/` は gitignore。Zod と同じ）。判断は変えない。

---

## 参考

- TASK-003 Phase B（本番 FCM）: ADR 0007 の cron + `device_tokens` + FCM SDK。TASK-003 完了後に別タスク化する。
- TASK-004 は `scratch/input.ts` でのバンドル計測より先に Mini へ書き換えない。
- TASK-005 は人が「着手して」と言うまで ESLint を外さない。
