import 'package:equatable/equatable.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.records = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<HistoryRecord> records;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryRecord>? records,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, records, errorMessage];
}
