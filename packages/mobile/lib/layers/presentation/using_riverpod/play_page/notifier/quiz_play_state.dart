import 'package:equatable/equatable.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';

enum QuizPlayStatus { empty, playing, finished }

class QuizPlayState extends Equatable {
  const QuizPlayState({
    this.status = QuizPlayStatus.empty,
    this.pool = const [],
    this.quizIds = const [],
    this.sessionId = '',
    this.sectionFilter,
    this.startedAt = '',
    this.currentIndex = 0,
    this.selectedIndex,
    this.revealed = false,
    this.answers = const [],
    this.completedRecord,
  });

  final QuizPlayStatus status;
  final List<Quiz> pool;
  final List<int> quizIds;
  final String sessionId;
  final String? sectionFilter;
  final String startedAt;
  final int currentIndex;
  final int? selectedIndex;
  final bool revealed;
  final List<QuizAnswer> answers;
  final HistoryRecord? completedRecord;

  Quiz? get currentQuiz {
    if (currentIndex < 0 || currentIndex >= quizIds.length) return null;
    final id = quizIds[currentIndex];
    for (final quiz in pool) {
      if (quiz.id == id) return quiz;
    }
    return null;
  }

  bool get isLast => currentIndex >= quizIds.length - 1 && quizIds.isNotEmpty;

  QuizPlayState copyWith({
    QuizPlayStatus? status,
    List<Quiz>? pool,
    List<int>? quizIds,
    String? sessionId,
    String? sectionFilter,
    bool clearSectionFilter = false,
    String? startedAt,
    int? currentIndex,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    bool? revealed,
    List<QuizAnswer>? answers,
    HistoryRecord? completedRecord,
  }) {
    return QuizPlayState(
      status: status ?? this.status,
      pool: pool ?? this.pool,
      quizIds: quizIds ?? this.quizIds,
      sessionId: sessionId ?? this.sessionId,
      sectionFilter: clearSectionFilter ? null : sectionFilter ?? this.sectionFilter,
      startedAt: startedAt ?? this.startedAt,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: clearSelectedIndex ? null : selectedIndex ?? this.selectedIndex,
      revealed: revealed ?? this.revealed,
      answers: answers ?? this.answers,
      completedRecord: completedRecord ?? this.completedRecord,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pool,
        quizIds,
        sessionId,
        sectionFilter,
        startedAt,
        currentIndex,
        selectedIndex,
        revealed,
        answers,
        completedRecord,
      ];
}
