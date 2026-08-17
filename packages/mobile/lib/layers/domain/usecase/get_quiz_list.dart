import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';

class GetQuizList {
  GetQuizList({
    required QuizRepository repository,
  }) : _repository = repository;

  final QuizRepository _repository;

  Future<List<Quiz>> call() {
    return _repository.getQuizList();
  }
}
