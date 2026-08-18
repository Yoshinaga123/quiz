import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/usecase/clear_history.dart';
import 'package:quiz_mobile/layers/domain/usecase/load_history.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_page/notifier/history_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_providers.dart';

final historyStateProvider =
    StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(
    loadHistory: ref.read(loadHistoryProvider),
    clearHistory: ref.read(clearHistoryProvider),
  ),
);

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier({
    required LoadHistory loadHistory,
    required ClearHistory clearHistory,
  })  : _loadHistory = loadHistory,
        _clearHistory = clearHistory,
        super(const HistoryState());

  final LoadHistory _loadHistory;
  final ClearHistory _clearHistory;

  Future<void> load() async {
    state = state.copyWith(status: HistoryStatus.loading, clearErrorMessage: true);
    try {
      final records = await _loadHistory();
      records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      state = state.copyWith(status: HistoryStatus.success, records: records);
    } catch (error) {
      state = state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> clear() async {
    await _clearHistory();
    state = const HistoryState(status: HistoryStatus.success);
  }
}
