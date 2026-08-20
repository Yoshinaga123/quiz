import 'package:quiz_mobile/layers/domain/entity/history_record.dart';

abstract class HistoryRepository {
  Future<List<HistoryRecord>> load();
  Future<void> append(HistoryRecord record);
  Future<void> clear();
}
