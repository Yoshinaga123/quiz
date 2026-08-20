import 'dart:convert';

import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

const historyStorageKey = 'quzzes:history:v1';

class HistoryLocalDataSource {
  HistoryLocalDataSource({required SharedPreferences preferences})
      : _preferences = preferences;

  final SharedPreferences _preferences;

  List<HistoryRecord> load() {
    final raw = _preferences.getString(historyStorageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map((item) {
            if (item is! Map) {
              throw const FormatException('history item must be an object');
            }
            return HistoryRecord.fromJson(Map<String, Object?>.from(item));
          })
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> save(List<HistoryRecord> records) {
    return _preferences.setString(
      historyStorageKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }

  Future<void> clear() {
    return _preferences.remove(historyStorageKey);
  }
}
