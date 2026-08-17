import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

/// `GET /v1/quizzes` / `GET /v1/quizzes/{id}` のレスポンス要素に対応する DTO。
///
/// docs/api/public-quiz-api.yaml の `#/components/schemas/Quiz` と一対一。
/// 既存の `data/dto/quiz_dto.dart` には触れず、Public API 用に新設する。
class PublicQuizDto {
  const PublicQuizDto({
    required this.id,
    required this.section,
    required this.title,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.source,
    this.code,
  });

  final int id;
  final String section;
  final String title;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String source;
  final String? code;

  factory PublicQuizDto.fromJson(Map<String, dynamic> json) {
    final id = _readInt(json, 'id');
    final section = _readNonEmptyString(json, 'section');
    final title = _readNonEmptyString(json, 'title');
    final question = _readNonEmptyString(json, 'question');
    final explanation = _readNonEmptyString(json, 'explanation');
    final source = _readNonEmptyString(json, 'source');
    final correctAnswerIndex = _readInt(json, 'correctAnswerIndex');

    final rawOptions = json['options'];
    if (rawOptions is! List || rawOptions.length < 2) {
      throw const QuizParseFailure(
        message: 'options must be a list with at least 2 entries',
      );
    }
    final options = rawOptions
        .map((value) {
          if (value is! String || value.isEmpty) {
            throw const QuizParseFailure(
              message: 'options entries must be non-empty strings',
            );
          }
          return value;
        })
        .toList(growable: false);

    if (correctAnswerIndex < 0 || correctAnswerIndex >= options.length) {
      throw QuizParseFailure(
        message:
            'correctAnswerIndex $correctAnswerIndex out of range (options=${options.length})',
      );
    }

    final rawCode = json['code'];
    String? code;
    if (rawCode is String && rawCode.isNotEmpty) {
      code = rawCode;
    } else if (rawCode != null && rawCode is! String) {
      throw const QuizParseFailure(message: 'code must be a string when present');
    }

    return PublicQuizDto(
      id: id,
      section: section,
      title: title,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
      source: source,
      code: code,
    );
  }

  Quiz toEntity() {
    return Quiz(
      id: id,
      section: section,
      title: title,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      explanation: explanation,
      source: source,
      code: code,
    );
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw QuizParseFailure(message: '$key must be an integer');
  }

  static String _readNonEmptyString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw QuizParseFailure(message: '$key must be a non-empty string');
    }
    return value;
  }
}
