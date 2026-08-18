import 'package:equatable/equatable.dart';

class QuizAnswer extends Equatable {
  const QuizAnswer({
    required this.quizId,
    required this.selectedIndex,
    required this.correct,
  });

  final int quizId;
  final int selectedIndex;
  final bool correct;

  Map<String, Object?> toJson() {
    return {
      'quizId': quizId,
      'selectedIndex': selectedIndex,
      'correct': correct,
    };
  }

  factory QuizAnswer.fromJson(Map<String, Object?> json) {
    return QuizAnswer(
      quizId: (json['quizId'] as num).toInt(),
      selectedIndex: (json['selectedIndex'] as num).toInt(),
      correct: json['correct'] as bool,
    );
  }

  @override
  List<Object?> get props => [quizId, selectedIndex, correct];
}

class HistoryRecord extends Equatable {
  const HistoryRecord({
    required this.id,
    required this.sectionFilter,
    required this.total,
    required this.correct,
    required this.startedAt,
    required this.completedAt,
    required this.answers,
  });

  final String id;
  final String? sectionFilter;
  final int total;
  final int correct;
  final String startedAt;
  final String completedAt;
  final List<QuizAnswer> answers;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'sectionFilter': sectionFilter,
      'total': total,
      'correct': correct,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  factory HistoryRecord.fromJson(Map<String, Object?> json) {
    final rawAnswers = json['answers'];
    if (rawAnswers is! List) {
      throw const FormatException('history answers must be a list');
    }
    return HistoryRecord(
      id: json['id'] as String,
      sectionFilter: json['sectionFilter'] as String?,
      total: (json['total'] as num).toInt(),
      correct: (json['correct'] as num).toInt(),
      startedAt: json['startedAt'] as String,
      completedAt: json['completedAt'] as String,
      answers: rawAnswers.map((item) {
        if (item is! Map) {
          throw const FormatException('history answer must be an object');
        }
        return QuizAnswer.fromJson(Map<String, Object?>.from(item));
      }).toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        sectionFilter,
        total,
        correct,
        startedAt,
        completedAt,
        answers,
      ];
}
