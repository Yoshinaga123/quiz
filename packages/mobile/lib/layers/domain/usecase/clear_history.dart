import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';

class ClearHistory {
  ClearHistory({required HistoryRepository repository}) : _repository = repository;

  final HistoryRepository _repository;

  Future<void> call() {
    return _repository.clear();
  }
}
