import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/public_quiz_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

void main() {
  group('PublicQuizDto.fromJson', () {
    final validJson = <String, dynamic>{
      'id': 1,
      'section': 'React & TypeScript',
      'title': 'useEffect の依存配列',
      'question': '依存配列の役割は？',
      'options': ['再実行する', '止める', '無視する', '無効化する'],
      'correctAnswerIndex': 0,
      'explanation': '依存値が変わると再実行されます。',
      'source': 'React docs',
      'code': 'useEffect(() => {}, [userId]);',
    };

    test('valid payload を Quiz エンティティに変換できる', () {
      final dto = PublicQuizDto.fromJson(validJson);
      final quiz = dto.toEntity();

      expect(quiz.id, 1);
      expect(quiz.section, 'React & TypeScript');
      expect(quiz.options, hasLength(4));
      expect(quiz.correctAnswerIndex, 0);
      expect(quiz.code, 'useEffect(() => {}, [userId]);');
    });

    test('code が省略されていても許容される', () {
      final json = Map<String, dynamic>.from(validJson)..remove('code');
      final dto = PublicQuizDto.fromJson(json);
      expect(dto.code, isNull);
    });

    test('options が 1 件しかない場合は QuizParseFailure を投げる', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['options'] = ['唯一'];
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('correctAnswerIndex が options の範囲外なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['correctAnswerIndex'] = 99;
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('section が空文字なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(validJson)..['section'] = '';
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('id が数値以外なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(validJson)..['id'] = 'one';
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });
  });
}
