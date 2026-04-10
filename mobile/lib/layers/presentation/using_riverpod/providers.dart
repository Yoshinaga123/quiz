import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/quiz_repository_impl.dart';
import 'package:quiz_mobile/layers/data/source/local/quiz_local_data_source.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_details.dart';
import 'package:quiz_mobile/layers/domain/usecase/get_quiz_list.dart';

final quizLocalDataSourceProvider = Provider<QuizLocalDataSource>(
  (ref) => QuizLocalDataSourceImpl(),
);

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(
    localDataSource: ref.read(quizLocalDataSourceProvider),
  ),
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
