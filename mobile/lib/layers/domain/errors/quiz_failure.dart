import 'package:equatable/equatable.dart';

/// 公開クイズ API（ADR 0006）呼び出しで発生する失敗の sealed 階層。
///
/// ADR 0009 で「`Result<T, E>` 風の sealed class を `domain/errors/` に置き、
/// UI で `when` 分岐」と決めた指針に沿って導入する。
/// 既存の例外ベースのフロー（`QuizLocalDataSourceImpl` 経路）には影響しない。
sealed class QuizFailure extends Equatable implements Exception {
  const QuizFailure({this.message});

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

/// ネットワーク到達失敗・タイムアウト・ソケット切断などの輸送層エラー。
class QuizNetworkFailure extends QuizFailure {
  const QuizNetworkFailure({super.message});
}

/// 指定 ID のクイズが存在しない（HTTP 404）。
class QuizNotFoundFailure extends QuizFailure {
  const QuizNotFoundFailure({super.message});
}

/// サーバー由来の 4xx / 5xx（404 を除く）。
class QuizServerFailure extends QuizFailure {
  const QuizServerFailure({
    required this.statusCode,
    super.message,
  });

  final int statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// レスポンスボディの JSON / DTO 解析に失敗。
class QuizParseFailure extends QuizFailure {
  const QuizParseFailure({super.message});
}
