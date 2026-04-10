import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuizList();
  Future<Quiz> getQuizDetails({required int id});
}
