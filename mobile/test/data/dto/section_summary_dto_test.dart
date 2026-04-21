import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/section_summary_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

void main() {
  group('SectionSummaryDto.fromJson', () {
    test('正常な値からエンティティに変換できる', () {
      final dto = SectionSummaryDto.fromJson({'section': 'CSS', 'count': 3});
      final entity = dto.toEntity();
      expect(entity.section, 'CSS');
      expect(entity.count, 3);
    });

    test('section が空なら QuizParseFailure', () {
      expect(
        () => SectionSummaryDto.fromJson({'section': '', 'count': 1}),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('count が負の値なら QuizParseFailure', () {
      expect(
        () => SectionSummaryDto.fromJson({'section': 'CSS', 'count': -1}),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('count が int でなければ QuizParseFailure', () {
      expect(
        () => SectionSummaryDto.fromJson({'section': 'CSS', 'count': '3'}),
        throwsA(isA<QuizParseFailure>()),
      );
    });
  });
}
