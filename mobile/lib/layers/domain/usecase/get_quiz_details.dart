import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';

class GetQuizDetails {
  GetQuizDetails({
    required QuizRepository repository,
  }) : _repository = repository;

  final QuizRepository _repository;

  Future<Quiz> call({required int id}) {
    return _repository.getQuizDetails(id: id);
  }
}
