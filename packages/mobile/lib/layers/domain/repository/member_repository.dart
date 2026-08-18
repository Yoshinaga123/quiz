import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
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

  /// セッションを破棄する（ローカルのみ）。バックエンドの delete は [deleteAccount] を使う。
  Future<void> signOut();

  /// 会員をソフト削除し、セッションもクリアする。
  Future<void> deleteAccount(MemberSession session);
}
