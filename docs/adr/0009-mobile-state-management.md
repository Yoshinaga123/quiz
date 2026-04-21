# ADR 0009: モバイル版の状態管理と層構造

- Status: Accepted
- Date: 2026-04-21
- Deciders: Quiz App Team
- Related: ADR 0005, ADR 0006

## Context

`mobile/` は Flutter ベースで、`flutter_riverpod` と Clean Architecture 風の `layers/` 構成だけ導入済み。
今後、API 連携・履歴・通知購読などが入ると、状態管理ライブラリの選定とレイヤ間の責務が曖昧なままだと
コードが急速に絡まり合うリスクがある。

## Decision

| 軸 | 採用 |
| --- | --- |
| 状態管理 | **Riverpod (`flutter_riverpod`) のみ** |
| 副作用境界 | `domain` 層に **Repository インターフェース** を置き、`data` 層で実装 |
| データソース | `data/source/local/...` と `data/source/remote/...` に分割 |
| Immutable モデル | `equatable` ベース（既存）。Freezed は採用しない（生成コードのコストを避けるため） |
| エラー表現 | `Result<T, E>` 風の sealed class を `domain/errors/` に定義し、UI で `when` 分岐 |
| ナビゲーション | `Navigator 2.0` ではなく **`MaterialApp.router` + go_router** を v1 後半に導入予定 |
| プッシュ通知 | ADR 0007 に従い FCM。受信ハンドリングは `presentation` 層から外し、専用サービスに切り出す |

## Rationale

- **Riverpod 単一化**: Provider と Riverpod の混在は典型的な失敗パターン。プロジェクト発足時に統一する。
- **Repository インターフェース**: `domain` 層を Flutter 非依存に保ち、ユニットテストを Pure Dart で書ける。
- **Freezed 不採用**: `pubspec.yaml` を軽く保ち、CI 時間とメンテ負荷を削減。複雑な sealed が必要になったら再評価。
- **go_router**: deep link（プッシュ通知タップ）と Web Push 将来対応を見据えた標準的な選択。

## Consequences

### Positive

- 学習コストが Riverpod に集約される。
- `domain` 層のテスト容易性が高く、CI で軽量に回せる。

### Negative

- Freezed を入れない代わりに、複雑な状態クラスを書くときは手書きの `copyWith` / `==` が増える。

## Migration Plan

1. `lib/layers/domain/` 直下に Repository インターフェースを定義。
2. 既存の `quiz_local_data_source.dart` を `data/source/local/` 配下に整理し、
   `data/repositories/` で Repository を実装。
3. ADR 0006 の API 公開後、`data/source/remote/quiz_remote_data_source.dart` を追加して切替可能にする。
4. `presentation` 層は `Provider` を直接持たず、Riverpod の `Notifier` 経由でのみ Repository に触る。
