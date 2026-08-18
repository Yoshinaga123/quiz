import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/data/source/local/member_session_storage.dart';
import 'package:quiz_mobile/layers/data/source/remote/member_api_client.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';
import 'package:quiz_mobile/layers/domain/repository/member_repository.dart';

/// [MemberRepository] の実装。
///
/// - リモート呼び出しは [MemberApiClient] に、セッションの永続化は
///   [MemberSessionStorage] に委譲する（clean architecture の依存方向）。
/// - サインイン成功後は必ずセッションをストレージへ保存し、以降の起動で
///   [restoreSession] が同じセッションを返すようにする。
class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl({
    required MemberApiClient client,
    required MemberSessionStorage storage,
  })  : _client = client,
        _storage = storage;

  final MemberApiClient _client;
  final MemberSessionStorage _storage;

  @override
  Future<MemberSession?> restoreSession() => _storage.read();

  @override
  Future<MemberSession> registerAndSignIn({
    required String handle,
    required String password,
  }) async {
    await _client.registerMember(handle: handle, password: password);
    return signIn(handle: handle, password: password);
  }

  @override
  Future<MemberSession> signIn({
    required String handle,
    required String password,
  }) async {
    final token = await _client.createSession(handle: handle, password: password);
    final me = await _client.fetchMe(token: token);
    final session = MemberSession(
      memberId: me.id,
      handle: me.handle,
      token: token,
    );
    await _storage.write(session);
    return session;
  }

  @override
  Future<PublicMemberDto> fetchMe(MemberSession session) {
    return _client.fetchMe(token: session.token);
  }

  @override
  Future<List<AnswerHistoryEntryDto>> fetchAnswerHistory(
    MemberSession session, {
    int? quizId,
    int? limit,
  }) async {
    final result = await _client.listAnswerHistory(
      token: session.token,
      quizId: quizId,
      limit: limit,
    );
    return result.items;
  }

  @override
  Future<AnswerHistoryEntryDto> recordAnswer(
    MemberSession session, {
    required int quizId,
    required int selectedIndex,
  }) {
    return _client.createAnswer(
      token: session.token,
      quizId: quizId,
      selectedIndex: selectedIndex,
    );
  }

  @override
  Future<void> signOut() => _storage.clear();

  @override
  Future<void> deleteAccount(MemberSession session) async {
    await _client.deleteMe(token: session.token);
    await _storage.clear();
  }
}
