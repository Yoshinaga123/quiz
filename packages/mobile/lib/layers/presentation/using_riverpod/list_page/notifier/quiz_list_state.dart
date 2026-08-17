import 'package:equatable/equatable.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

enum QuizListStatus { initial, loading, success, failure }

class QuizListState extends Equatable {
  const QuizListState({
    this.status = QuizListStatus.initial,
    this.quizzes = const [],
    this.errorMessage,
  });

  final QuizListStatus status;
  final List<Quiz> quizzes;
  final String? errorMessage;

  QuizListState copyWith({
    QuizListStatus? status,
    List<Quiz>? quizzes,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return QuizListState(
      status: status ?? this.status,
      quizzes: quizzes ?? this.quizzes,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, quizzes, errorMessage];
}
