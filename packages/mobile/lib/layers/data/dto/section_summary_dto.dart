import 'package:quiz_mobile/layers/domain/entity/section_summary.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

class SectionSummaryDto {
  const SectionSummaryDto({
    required this.section,
    required this.count,
  });

  final String section;
  final int count;

  factory SectionSummaryDto.fromJson(Map<String, dynamic> json) {
    final section = json['section'];
    final count = json['count'];
    if (section is! String || section.isEmpty) {
      throw const QuizParseFailure(
        message: 'section must be a non-empty string',
      );
    }
    if (count is! int || count < 0) {
      throw const QuizParseFailure(
        message: 'count must be a non-negative integer',
      );
    }
    return SectionSummaryDto(section: section, count: count);
  }

  SectionSummary toEntity() => SectionSummary(section: section, count: count);
}
