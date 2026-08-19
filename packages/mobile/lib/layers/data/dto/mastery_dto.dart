import 'package:equatable/equatable.dart';

/// `GET /api/me/mastery` 由来の 1 件。
///
/// docs/api/member-api.yaml `#/components/schemas/MasteryEntry` と一対一。
/// server は answer_history から都度導出するため、mobile 側で streak を計算せず
/// このまま表示に使う。
class MasteryEntryDto extends Equatable {
  const MasteryEntryDto({
    required this.quizId,
    required this.streak,
  });

  final int quizId;
  final int streak;

  factory MasteryEntryDto.fromJson(Map<String, dynamic> json) {
    final quizId = _readInt(json, 'quizId');
    final streak = _readInt(json, 'streak');
    if (quizId < 1) {
      throw const FormatException('quizId must be >= 1');
    }
    if (streak < 0) {
      throw const FormatException('streak must be >= 0');
    }
    return MasteryEntryDto(quizId: quizId, streak: streak);
  }

  @override
  List<Object?> get props => [quizId, streak];
}

/// `GET /api/me/mastery` レスポンス全体。
class MasteryResponseDto extends Equatable {
  const MasteryResponseDto({
    required this.items,
    required this.streakCap,
  });

  final List<MasteryEntryDto> items;
  final int streakCap;

  factory MasteryResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException('items must be an array');
    }
    final items = rawItems
        .map((raw) {
          if (raw is! Map<String, dynamic>) {
            throw const FormatException('mastery entry must be a JSON object');
          }
          return MasteryEntryDto.fromJson(raw);
        })
        .toList(growable: false);
    return MasteryResponseDto(
      items: items,
      streakCap: _readInt(json, 'streakCap'),
    );
  }

  @override
  List<Object?> get props => [items, streakCap];
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('$key must be an integer');
}
