import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

Map<String, dynamic> _loadFixture(String name) {
  final candidates = [
    File('../../docs/api/fixtures/$name'),
    File('docs/api/fixtures/$name'),
  ];
  for (final file in candidates) {
    if (file.existsSync()) {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  throw StateError('docs/api/fixtures/$name not found');
}

void main() {
  group('AnswerHistoryListDto.fromJson', () {
    test('fixtures/answer-history-list.json を 2 件パースできる', () {
      final dto = AnswerHistoryListDto.fromJson(
        _loadFixture('answer-history-list.json'),
      );

      expect(dto.items, hasLength(2));
      expect(dto.items[0].id, 2);
      expect(dto.items[0].isCorrect, isTrue);
      expect(dto.items[0].quizId, 42);
      expect(dto.items[1].isCorrect, isFalse);
    });

    test('items が list でないと MemberParseFailure', () {
      expect(
        () => AnswerHistoryListDto.fromJson(<String, dynamic>{'items': 'nope'}),
        throwsA(isA<MemberParseFailure>()),
      );
    });
  });

  group('AnswerHistoryEntryDto.fromJson', () {
    Map<String, dynamic> baseEntry() => {
          'id': 1,
          'quizId': 42,
          'selectedIndex': 0,
          'isCorrect': true,
          'answeredAt': '2026-08-18T12:00:00.000Z',
        };

    test('正常データはパースできる', () {
      final dto = AnswerHistoryEntryDto.fromJson(baseEntry());
      expect(dto.answeredAt.year, 2026);
    });

    test('selectedIndex が負なら MemberParseFailure', () {
      final json = baseEntry()..['selectedIndex'] = -1;
      expect(
        () => AnswerHistoryEntryDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });

    test('isCorrect が bool でないと MemberParseFailure', () {
      final json = baseEntry()..['isCorrect'] = 'true';
      expect(
        () => AnswerHistoryEntryDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });

    test('answeredAt が不正な文字列なら MemberParseFailure', () {
      final json = baseEntry()..['answeredAt'] = 'yesterday';
      expect(
        () => AnswerHistoryEntryDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });

    test('quizId が 0 だと MemberParseFailure', () {
      final json = baseEntry()..['quizId'] = 0;
      expect(
        () => AnswerHistoryEntryDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });
  });
}
