import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/quiz_remote_repository_impl.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_remote_data_source.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_section_repository.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_details.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_list.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_section_summaries.dart';

/// 公開 API（ADR 0006）連携用の Riverpod プロバイダ群。
///
/// 既存の `providers.dart`（local data source 配線）は手を入れずにそのまま残し、
/// remote へ切り替えたい画面が `*Remote` プロバイダを参照することで段階移行できる。
///
/// 接続先のベース URL は QuizApiClient の規定に従い、
/// `--dart-define=QUIZ_API_BASE_URL=...` で上書き可能（既定 `localhost:8082`）。
final quizApiClientProvider = Provider<QuizApiClient>((ref) {
  final client = QuizApiClient();
  ref.onDispose(client.close);
  return client;
});

final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>(
  (ref) => QuizRemoteDataSourceImpl(client: ref.watch(quizApiClientProvider)),
);

/// remote リポジトリの単一インスタンスを供給する内部プロバイダ。
/// `QuizRemoteRepositoryImpl` は `QuizRepository` と `QuizSectionRepository` の
/// 両方を実装しているため、これを 2 つのインターフェース別エイリアスへ展開する。
final _quizRemoteRepositoryImplProvider = Provider<QuizRemoteRepositoryImpl>(
  (ref) => QuizRemoteRepositoryImpl(
    remoteDataSource: ref.watch(quizRemoteDataSourceProvider),
  ),
);

/// remote 経路の `QuizRepository`。
/// 既存の `quizRepositoryProvider`（local）と意図的に名前を分け、
/// 競合せずに共存できるようにしている。
final quizRemoteRepositoryProvider = Provider<QuizRepository>(
  (ref) => ref.watch(_quizRemoteRepositoryImplProvider),
);

/// 同じ実装を `QuizSectionRepository` として露出する。
/// Riverpod では `Provider.family` 等を使わずに型ごとに別エイリアスを置く方が
/// UI 側で `ref.watch` した時の型推論がシンプルになる。
final quizSectionRemoteRepositoryProvider = Provider<QuizSectionRepository>(
  (ref) => ref.watch(_quizRemoteRepositoryImplProvider),
);

final getQuizListRemoteProvider = Provider<GetQuizList>(
  (ref) => GetQuizList(
    repository: ref.watch(quizRemoteRepositoryProvider),
  ),
);

final getQuizDetailsRemoteProvider = Provider<GetQuizDetails>(
  (ref) => GetQuizDetails(
    repository: ref.watch(quizRemoteRepositoryProvider),
  ),
);

final getSectionSummariesRemoteProvider = Provider<GetSectionSummaries>(
  (ref) => GetSectionSummaries(
    repository: ref.watch(quizSectionRemoteRepositoryProvider),
  ),
);
