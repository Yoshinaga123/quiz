import 'package:quiz_mobile/layers/data/source/local/history_local_data_source.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/repository/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _loadPreferences;
  HistoryLocalDataSource? _dataSource;

  Future<HistoryLocalDataSource> _source() async {
    return _dataSource ??= HistoryLocalDataSource(
      preferences: await _loadPreferences(),
    );
  }

  @override
  Future<List<HistoryRecord>> load() async {
    return (await _source()).load();
  }

  @override
  Future<void> append(HistoryRecord record) async {
    final source = await _source();
    final next = [...source.load(), record];
    await source.save(next);
  }

  @override
  Future<void> clear() async {
    await (await _source()).clear();
  }
}
