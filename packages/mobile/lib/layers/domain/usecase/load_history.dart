import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';

class LoadHistory {
  LoadHistory({required HistoryRepository repository}) : _repository = repository;

  final HistoryRepository _repository;

  Future<List<HistoryRecord>> call() {
    return _repository.load();
  }
}
