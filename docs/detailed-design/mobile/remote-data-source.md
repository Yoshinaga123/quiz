---
title: Remote data source
description: How the Flutter client calls the public quiz API without changing the local data path
---

# Remote Data Source（公開クイズ API 連携）

このドキュメントは `packages/mobile/` から公開 API（[ADR 0006](../../adr/0006-public-quiz-api.md) /
[`docs/api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)）を呼ぶための
追加レイヤの使い方をまとめる。

既存の local data source 経路（`QuizLocalDataSourceImpl` → `QuizRepositoryImpl` →
`providers.dart` の `quizRepositoryProvider`）には**意図的に手を入れず**、
remote 経路を**並行配置**することで段階的な切り替えを可能にする。

## レイヤ構成（追加分のみ）

```text
lib/layers/
├── domain/
│   ├── entity/section_summary.dart                ← 新
│   ├── errors/quiz_failure.dart                   ← 新（sealed: Network/NotFound/Server/Parse）
│   ├── repository/quiz_section_repository.dart    ← 新
│   └── usecase/get_section_summaries.dart         ← 新
├── data/
│   ├── dto/public_quiz_dto.dart                   ← 新（fromJson + toEntity）
│   ├── dto/section_summary_dto.dart               ← 新
│   ├── source/remote/
│   │   ├── quiz_api_client.dart                   ← 新（dart:io HttpClient のみで構成）
│   │   └── quiz_remote_data_source.dart           ← 新
│   └── quiz_remote_repository_impl.dart           ← 新（QuizRepository + QuizSectionRepository を実装）
└── presentation/using_riverpod/
    └── remote_providers.dart                      ← 新（既存 providers.dart と並行）
```

## 設計原則

- **`pubspec.yaml` を変更しない**: `http` などの追加依存を入れず、
  `dart:io` の `HttpClient` と `dart:convert` だけで HTTP/JSON を扱う。
- **失敗は sealed class**: `QuizApiClient` / DTO は必ず `QuizFailure` の
  サブタイプ（`QuizNetworkFailure` / `QuizNotFoundFailure` / `QuizServerFailure`
  / `QuizParseFailure`）を投げる。UI 側は `switch` で type narrow できる。
- **DTO は新ファイルに分離**: 既存の `data/dto/quiz_dto.dart` には触れず、
  Public API 用の `PublicQuizDto` を別ファイルとして追加。
- **Provider 名は意図的に分ける**: `quizRepositoryProvider`（local）と
  `quizRemoteRepositoryProvider`（remote）を共存させ、画面ごとに段階移行できる。

## ベース URL の指定

`QuizApiClient` は `String.fromEnvironment` でビルド時定数を読む。

```bash
flutter run \
  --dart-define=QUIZ_API_BASE_URL=http://10.0.2.2:8082
```

| 接続先 | 推奨ベース URL |
| --- | --- |
| iOS シミュレータ → ホスト Mac | `http://localhost:8082` |
| Android エミュレータ → ホスト | `http://10.0.2.2:8082` |
| 実機 → 同一 LAN の dev マシン | `http://<host-ip>:8082` |
| 本番 | `https://socrates-quiz.jp`（公開ポート **443**） |

未指定時の既定値は `http://localhost:8082`（`packages/backend/docker-compose.yml` の
ポートマッピング `8082:8080` に合わせている）。本番は `https://socrates-quiz.jp` の HTTPS 443 で公開する。

## 切り替え方（既存画面に影響なし）

`presentation/using_riverpod/remote_providers.dart` から必要なユースケースを
そのまま参照するだけで、新画面を remote 経路にできる。

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/remote_providers.dart';

class RemoteQuizListPage extends ConsumerWidget {
  const RemoteQuizListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useCase = ref.watch(getQuizListRemoteProvider);
    // useCase() で /v1/quizzes を呼ぶ（limit 未指定時は offset で全ページ取得）
    ...
  }
}
```

既存の `QuizListPage` / `QuizDetailsPage` は `providers.dart` の
local 用プロバイダを参照しているため、本変更で挙動が変わることはない。

## エラーハンドリング例

```dart
try {
  final quizzes = await useCase();
} on QuizFailure catch (failure) {
  switch (failure) {
    case QuizNetworkFailure():
      // ネットワーク不通／タイムアウト
    case QuizNotFoundFailure():
      // 404
    case QuizServerFailure(:final statusCode):
      // 4xx/5xx（404 を除く）
    case QuizParseFailure():
      // レスポンスの形が壊れている
  }
}
```

## テスト

`packages/mobile/test/` 以下に以下のテストを配置している。
ローカルに Flutter ツールチェーンが入っていれば
`flutter test` で実行できる（`http` 等の追加依存は不要）。

| テスト | 対象 |
| --- | --- |
| `test/data/dto/public_quiz_dto_test.dart` | `PublicQuizDto.fromJson` のバリデーション |
| `test/data/dto/section_summary_dto_test.dart` | `SectionSummaryDto.fromJson` |
| `test/data/source/remote/quiz_api_client_test.dart` | 実 `HttpServer` を立てて 200/404/500/壊れ JSON を検証 |
| `test/data/quiz_remote_repository_impl_test.dart` | Fake 実装を使った変換と例外透過 |

## 関連ドキュメント

- [ADR 0006: Public Quiz API の仕様分離](../../adr/0006-public-quiz-api.md)
- [ADR 0009: モバイル版の状態管理と層構造](../../adr/0009-mobile-state-management.md)
- [`docs/api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)
