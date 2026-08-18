import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';

class AppendHistoryRecord {
  AppendHistoryRecord({required HistoryRepository repository})
      : _repository = repository;

  final HistoryRepository _repository;

  Future<void> call(HistoryRecord record) {
    return _repository.append(record);
  }
}
