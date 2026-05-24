import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/push_feed_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

void main() {
  group('PushFeedDto.fromJson', () {
    final validJson = <String, dynamic>{
      'deliveryId': 1001,
      'quizId': 42,
      'title': 'Go の defer',
      'body': 'defer はいつ実行されますか？',
      'sentAt': '2026-05-25T02:05:00Z',
      'channel': 'mock',
    };

    test('valid payload を DTO に変換できる', () {
      final dto = PushFeedDto.fromJson(validJson);

      expect(dto.deliveryId, 1001);
      expect(dto.quizId, 42);
      expect(dto.title, 'Go の defer');
      expect(dto.channel, 'mock');
    });

    test('sentAt が日付でなければ QuizParseFailure', () {
      final json = Map<String, dynamic>.from(validJson)..['sentAt'] = 'invalid';

      expect(
        () => PushFeedDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('deliveryId が不正なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(validJson)..['deliveryId'] = 0;

      expect(
        () => PushFeedDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });
  });
}
