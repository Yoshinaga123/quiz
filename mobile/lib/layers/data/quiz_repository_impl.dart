import 'package:quiz_mobile/layers/data/source/local/quiz_local_data_source.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl({
    required QuizLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final QuizLocalDataSource _localDataSource;

  @override
  Future<List<Quiz>> getQuizList() async {
    final list = await _localDataSource.fetchQuizList();
    return list.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Quiz> getQuizDetails({required int id}) async {
    final dto = await _localDataSource.fetchQuizDetails(id: id);
    return dto.toEntity();
  }
}
