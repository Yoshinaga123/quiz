import 'package:equatable/equatable.dart';

/// 会員 API（ADR 0016）呼び出しで発生する失敗の sealed 階層。
/// `QuizFailure` と同じスタイル（ADR 0009）で分けている理由は、
/// UI 側で「クイズ取得の失敗」と「会員 API の失敗」を混同したくないため。
sealed class MemberFailure extends Equatable implements Exception {
  const MemberFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [runtimeType, message];

  @override
  String toString() {
    final base = runtimeType.toString();
    if (message == null || message!.isEmpty) return base;
    return '$base: $message';
  }
}

/// レスポンスボディの JSON / DTO 解析に失敗。
class MemberParseFailure extends MemberFailure {
  const MemberParseFailure({super.message});
}

/// ADR 0016 §6 で禁止されたフィールド（password_hash, createdAt など）を含んでいる。
class MemberForbiddenFieldFailure extends MemberFailure {
  const MemberForbiddenFieldFailure({required this.field, super.message});

  final String field;

  @override
  List<Object?> get props => [...super.props, field];
}
