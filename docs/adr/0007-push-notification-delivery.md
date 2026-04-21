# ADR 0007: プッシュ通知の配信方式

- Status: Proposed
- Date: 2026-04-21
- Deciders: Quiz App Team
- Related: quiz.md, ADR 0005, ADR 0006

## Context

`quiz.md` の要件で「**毎日 1 問のクイズをプッシュ通知** で配信する」ことが定められている。
現状:

- モバイルアプリ (`mobile/`) は Flutter のみで、通知ライブラリ未導入。
- 管理画面 (`admin-web/`) には各クイズに `pushEnabled` トグルが既に存在。
- バックエンドはプッシュ送信機構を持たない。

通知を「いつ・どのチャネルで・誰に・何を」送るかを決める必要がある。

## Decision

以下の構成で配信する。

| 軸 | 採用 |
| --- | --- |
| モバイル配信基盤 | **Firebase Cloud Messaging (FCM)** |
| Web 配信基盤 | **Web Push (VAPID)**。ただし当面は v1 では未対応とし、設計のみ用意 |
| 配信トリガー | バックエンド側の **cron ジョブ**（毎日 JST 09:00） |
| 送信対象クイズの選定 | `status = published` かつ `push_enabled = true` のクイズから 1 件を **疑似ランダム + 直近送信履歴除外** で選定 |
| 配信履歴 | `push_deliveries` テーブルで `quiz_id`, `sent_at`, `target_count`, `status` を記録 |
| デバイストークン | `device_tokens` テーブルにアプリ ID + プラットフォーム + トークンを保存。匿名 ID で良い |
| 個人情報 | 収集しない。プッシュトークンと匿名 ID のみ |

## Rationale

- **FCM**: iOS / Android の双方を単一 SDK で扱え、APNs 証明書管理を Firebase に委譲できる。
- **VAPID Web Push**: 将来 PC ユーザーにも届けられるが、対応コストが高いため v1 は除外。
- **cron**: 1 日 1 通であり、リアルタイム性は不要。Go バックエンドに `time.Tick` 相当の単純なスケジューラで足る。
- **直近送信履歴除外**: 直近 N 日間に配信したクイズを除外することで、同じ問題が連続して届く事故を防ぐ。

## Consequences

### Positive

- iOS / Android 双方の通知開発を 1 つの SDK に集約できる。
- 配信履歴がテーブル化され、運用上の問い合わせ対応がしやすい。

### Negative

- Firebase 利用に伴うコストとベンダーロックイン。月次のクォータ監視が必要。
- バックエンドに新たな副作用（外部送信）が増えるため、テスト方針（モック、フェイク FCM）を整える必要がある。

## Open Questions

- ユーザーに「曜日・時刻」を選ばせるか？ → v1 ではグローバル固定、v2 で個別化を検討。
- 通知タップ時のディープリンクは Web 版にも対応するか？ → `mobile/` 優先。
