import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';
import 'package:quiz_mobile/layers/domain/usecase/append_history_record.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/notifier/quiz_play_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/notifier/quiz_play_state.dart';

class _MemoryHistory implements HistoryRepository {
  HistoryRecord? last;

  @override
  Future<void> append(HistoryRecord record) async {
    last = record;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<List<HistoryRecord>> load() async => const [];
}

void main() {
  const quizzes = [
    Quiz(
      id: 1,
      section: 'React',
      title: 'A',
      question: 'q',
      options: ['right', 'wrong'],
      correctAnswerIndex: 0,
      explanation: 'e',
      source: 's',
    ),
  ];

  test('select, submit, next persist a local history record', () async {
    final history = _MemoryHistory();
    final notifier = QuizPlayNotifier(
      appendHistoryRecord: AppendHistoryRecord(repository: history),
    );
    notifier.start(quizzes: quizzes, sectionFilter: 'React', limit: 1);
    expect(notifier.state.status, QuizPlayStatus.playing);

    notifier.select(0);
    notifier.submit();
    expect(notifier.state.revealed, isTrue);
    expect(notifier.state.answers.single.correct, isTrue);

    await notifier.next();
    expect(notifier.state.status, QuizPlayStatus.finished);
    expect(history.last?.total, 1);
    expect(history.last?.correct, 1);
    expect(history.last?.sectionFilter, 'React');
  });
}
