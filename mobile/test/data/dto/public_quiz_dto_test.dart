import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/public_quiz_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

Map<String, dynamic> loadQuizFixture({String name = 'quiz.json'}) {
  final candidates = [
    File('../docs/api/fixtures/$name'),
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
  group('PublicQuizDto.fromJson', () {
    test('fixtures/quiz.json を Quiz エンティティに変換できる', () {
      final dto = PublicQuizDto.fromJson(loadQuizFixture());
      final quiz = dto.toEntity();

      expect(quiz.id, 1);
      expect(quiz.section, 'React');
      expect(quiz.options, hasLength(2));
      expect(quiz.correctAnswerIndex, 0);
      expect(quiz.code, 'const [value, setValue] = useState(0);');
    });

    test('code が省略されていても許容される', () {
      final json = Map<String, dynamic>.from(loadQuizFixture())..remove('code');
      final dto = PublicQuizDto.fromJson(json);
      expect(dto.code, isNull);
    });

    test('options が 1 件しかない場合は QuizParseFailure を投げる', () {
      final json = Map<String, dynamic>.from(loadQuizFixture())
        ..['options'] = ['唯一'];
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('fixtures/quiz-invalid-answer-index.json は QuizParseFailure', () {
      expect(
        () => PublicQuizDto.fromJson(
          loadQuizFixture(name: 'quiz-invalid-answer-index.json'),
        ),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('section が空文字なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(loadQuizFixture())..['section'] = '';
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('id が数値以外なら QuizParseFailure', () {
      final json = Map<String, dynamic>.from(loadQuizFixture())..['id'] = 'one';
      expect(
        () => PublicQuizDto.fromJson(json),
        throwsA(isA<QuizParseFailure>()),
      );
    });
  });
}
