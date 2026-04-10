import 'package:equatable/equatable.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

enum QuizDetailsStatus { initial, loading, success, failure }

class QuizDetailsState extends Equatable {
  const QuizDetailsState({
    this.status = QuizDetailsStatus.initial,
    this.quiz,
    this.errorMessage,
  });

  final QuizDetailsStatus status;
  final Quiz? quiz;
  final String? errorMessage;

  QuizDetailsState copyWith({
    QuizDetailsStatus? status,
    Quiz? quiz,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return QuizDetailsState(
      status: status ?? this.status,
      quiz: quiz ?? this.quiz,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, quiz, errorMessage];
}
