import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/mastery_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';

/// 会員リポジトリ（ADR 0016）。実バックエンドと会員セッションの永続化を隠す。
///
/// このインターフェースは domain 層の契約であり、`data/` 層で HTTP + セキュア
/// ストレージ実装を差し込む。UI 層はこの契約だけを参照する。
abstract class MemberRepository {
  /// 起動時にストレージから復元されたセッション（なければ null）。
  Future<MemberSession?> restoreSession();

  Future<MemberSession> registerAndSignIn({
    required String handle,
    required String password,
  });

  Future<MemberSession> signIn({
    required String handle,
    required String password,
  });

  Future<PublicMemberDto> fetchMe(MemberSession session);

  Future<List<AnswerHistoryEntryDto>> fetchAnswerHistory(
    MemberSession session, {
    int? quizId,
    int? limit,
  });

  Future<AnswerHistoryEntryDto> recordAnswer(
    MemberSession session, {
    required int quizId,
    required int selectedIndex,
  });

  /// ADR 0018 系のフォローアップ: 段位計算用の streak マップを取得する。
  Future<MasteryResponseDto> fetchMastery(MemberSession session);

  /// セッションを破棄する（ローカルのみ）。バックエンドの delete は [deleteAccount] を使う。
  Future<void> signOut();

  /// 会員をソフト削除し、セッションもクリアする。
  Future<void> deleteAccount(MemberSession session);

  /// ADR 0018 §3: email を登録/変更し、確認メール送信を要求する（202）。
  Future<void> setEmail(MemberSession session, {required String email});

  /// ADR 0018 §3: メール検証トークンを消費する（204）。
  Future<void> consumeEmailVerification({required String token});

  /// ADR 0018 §3: パスワード再設定リンクの送信を要求する（常に 202）。
  Future<void> requestPasswordReset({required String handleOrEmail});

  /// ADR 0018 §3: パスワード再設定を実行する（204）。
  Future<void> consumePasswordReset({
    required String token,
    required String newPassword,
  });
}
