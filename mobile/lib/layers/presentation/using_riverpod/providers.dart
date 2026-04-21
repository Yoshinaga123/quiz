import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/source/local/quiz_local_data_source.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_details.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_list.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/remote_providers.dart';

// quizLocalDataSourceProvider はテスト・オフライン検証用にそのまま残す。
// 公開クイズ API（ADR 0006）連携を主経路にしたため、本ファイルでは
// quizRepositoryProvider は remote 経路へ委譲する。
final quizLocalDataSourceProvider = Provider<QuizLocalDataSource>(
  (ref) => QuizLocalDataSourceImpl(),
);

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => ref.watch(quizRemoteRepositoryProvider),
);

final getQuizListProvider = Provider<GetQuizList>(
  (ref) => GetQuizList(
    repository: ref.read(quizRepositoryProvider),
  ),
);

final getQuizDetailsProvider = Provider<GetQuizDetails>(
  (ref) => GetQuizDetails(
    repository: ref.read(quizRepositoryProvider),
  ),
);
