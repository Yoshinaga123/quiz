import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

class QuizDto {
  const QuizDto({
    required this.id,
    required this.section,
    required this.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.source,
    this.code,
  });

  final int id;
  final String section;
  final String title;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String source;
  final String? code;

  Quiz toEntity() {
    return Quiz(
      id: id,
      section: section,
      title: title,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
      source: source,
      code: code,
    );
  }
}
