import 'package:equatable/equatable.dart';

/// 公開 API `GET /v1/sections` のレスポンス要素に対応する domain エンティティ。
///
/// docs/api/public-quiz-api.yaml の `#/components/schemas/SectionSummary` と一致。
class SectionSummary extends Equatable {
  const SectionSummary({
    required this.section,
    required this.count,
  });

  final String section;
  final int count;

  @override
  List<Object?> get props => [section, count];
}
