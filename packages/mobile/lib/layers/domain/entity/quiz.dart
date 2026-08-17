import 'package:equatable/equatable.dart';

class Quiz extends Equatable {
  const Quiz({
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

  String get correctAnswer => options[correctAnswerIndex];

  @override
  List<Object?> get props => [
        id,
        section,
        title,
        question,
        options,
        correctAnswerIndex,
        explanation,
        source,
        code,
      ];
}
