import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/source/local/history_local_data_source.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryLocalDataSource', () {
    test('round-trips a record', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final source = HistoryLocalDataSource(preferences: preferences);
      const record = HistoryRecord(
        id: 'session-1',
        sectionFilter: 'React',
        total: 1,
        correct: 1,
        startedAt: '2026-08-18T00:00:00.000Z',
        completedAt: '2026-08-18T00:01:00.000Z',
        answers: [
          QuizAnswer(quizId: 1, selectedIndex: 0, correct: true),
        ],
      );

      await source.save([record]);
      expect(source.load(), [record]);
    });

    test('corrupt JSON becomes an empty list', () async {
      SharedPreferences.setMockInitialValues({
        historyStorageKey: '{not-json',
      });
      final preferences = await SharedPreferences.getInstance();
      final source = HistoryLocalDataSource(preferences: preferences);
      expect(source.load(), isEmpty);
    });
  });
}
