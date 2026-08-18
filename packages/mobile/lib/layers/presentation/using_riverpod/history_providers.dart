import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/history_repository_impl.dart';
import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';
import 'package:quiz_mobile/layers/domain/usecase/append_history_record.dart';
import 'package:quiz_mobile/layers/domain/usecase/clear_history.dart';
import 'package:quiz_mobile/layers/domain/usecase/load_history.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(),
);

final loadHistoryProvider = Provider<LoadHistory>(
  (ref) => LoadHistory(repository: ref.watch(historyRepositoryProvider)),
);

final appendHistoryRecordProvider = Provider<AppendHistoryRecord>(
  (ref) => AppendHistoryRecord(repository: ref.watch(historyRepositoryProvider)),
);

final clearHistoryProvider = Provider<ClearHistory>(
  (ref) => ClearHistory(repository: ref.watch(historyRepositoryProvider)),
);
