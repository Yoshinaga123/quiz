import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';
import 'package:quiz_mobile/layers/domain/usecase/append_history_record.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_providers.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/notifier/quiz_play_state.dart';

final quizPlayStateProvider =
    StateNotifierProvider.autoDispose<QuizPlayNotifier, QuizPlayState>(
  (ref) => QuizPlayNotifier(
    appendHistoryRecord: ref.read(appendHistoryRecordProvider),
  ),
);

class QuizPlayNotifier extends StateNotifier<QuizPlayState> {
  QuizPlayNotifier({
    required AppendHistoryRecord appendHistoryRecord,
  })  : _appendHistoryRecord = appendHistoryRecord,
        super(const QuizPlayState());

  final AppendHistoryRecord _appendHistoryRecord;

  void start({
    required List<Quiz> quizzes,
    String? sectionFilter,
    int limit = defaultPlayLimit,
  }) {
    final quizIds = pickQuizIds(quizzes, sectionFilter, limit);
    if (quizIds.isEmpty) {
      state = const QuizPlayState(status: QuizPlayStatus.empty);
      return;
    }
    state = QuizPlayState(
      status: QuizPlayStatus.playing,
      pool: quizzes,
      quizIds: quizIds,
      sessionId: generateSessionId(),
      sectionFilter: sectionFilter,
      startedAt: nowIso(),
    );
  }

  void select(int index) {
    if (state.revealed || state.status != QuizPlayStatus.playing) return;
    state = state.copyWith(selectedIndex: index);
  }

  void submit() {
    final quiz = state.currentQuiz;
    final selected = state.selectedIndex;
    if (quiz == null || selected == null || state.revealed) return;
    final correct = isAnswerCorrect(quiz, selected);
    state = state.copyWith(
      revealed: true,
      answers: [
        ...state.answers,
        QuizAnswer(quizId: quiz.id, selectedIndex: selected, correct: correct),
      ],
    );
  }

  Future<void> next() async {
    if (!state.revealed || state.status != QuizPlayStatus.playing) return;
    if (!state.isLast) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedIndex: true,
        revealed: false,
      );
      return;
    }
    final correctCount = state.answers.where((answer) => answer.correct).length;
    final record = HistoryRecord(
      id: state.sessionId,
      sectionFilter: state.sectionFilter,
      total: state.quizIds.length,
      correct: correctCount,
      startedAt: state.startedAt,
      completedAt: nowIso(),
      answers: state.answers,
    );
    await _appendHistoryRecord(record);
    state = state.copyWith(
      status: QuizPlayStatus.finished,
      completedRecord: record,
    );
  }
}
