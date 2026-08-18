import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

/// `GET /api/me/answers` / `POST /api/me/answers` のレスポンス要素に対応する DTO。
///
/// docs/api/member-api.yaml の `#/components/schemas/AnswerHistoryEntry` と一対一。
/// `isCorrect` はサーバー側で `quizzes.correct_answer_index` と JOIN して算出される
/// （ADR 0016 §4）。クライアントで計算し直さないこと。
class AnswerHistoryEntryDto {
  const AnswerHistoryEntryDto({
    required this.id,
    required this.quizId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.answeredAt,
  });

  final int id;
  final int quizId;
  final int selectedIndex;
  final bool isCorrect;
  final DateTime answeredAt;

  factory AnswerHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    final id = _readPositiveInt(json, 'id');
    final quizId = _readPositiveInt(json, 'quizId');

    final rawIndex = json['selectedIndex'];
    if (rawIndex is! int || rawIndex < 0) {
      throw const MemberParseFailure(
        message: 'selectedIndex must be an integer >= 0',
      );
    }

    final isCorrect = json['isCorrect'];
    if (isCorrect is! bool) {
      throw const MemberParseFailure(message: 'isCorrect must be a boolean');
    }

    final rawAnsweredAt = json['answeredAt'];
    if (rawAnsweredAt is! String || rawAnsweredAt.isEmpty) {
      throw const MemberParseFailure(
        message: 'answeredAt must be an ISO-8601 string',
      );
    }
    final answeredAt = DateTime.tryParse(rawAnsweredAt);
    if (answeredAt == null) {
      throw MemberParseFailure(
        message: 'answeredAt is not a valid ISO-8601 timestamp: $rawAnsweredAt',
      );
    }

    return AnswerHistoryEntryDto(
      id: id,
      quizId: quizId,
      selectedIndex: rawIndex,
      isCorrect: isCorrect,
      answeredAt: answeredAt,
    );
  }

  static int _readPositiveInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int && value >= 1) return value;
    if (value is num && value >= 1) return value.toInt();
    throw MemberParseFailure(message: '$key must be an integer >= 1');
  }
}

/// `GET /api/me/answers` レスポンス全体に対応する DTO。
class AnswerHistoryListDto {
  const AnswerHistoryListDto({required this.items});

  final List<AnswerHistoryEntryDto> items;

  factory AnswerHistoryListDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const MemberParseFailure(message: 'items must be a list');
    }
    final items = <AnswerHistoryEntryDto>[];
    for (final raw in rawItems) {
      if (raw is! Map<String, dynamic>) {
        throw const MemberParseFailure(
          message: 'items entries must be JSON objects',
        );
      }
      items.add(AnswerHistoryEntryDto.fromJson(raw));
    }
    return AnswerHistoryListDto(items: List.unmodifiable(items));
  }
}
