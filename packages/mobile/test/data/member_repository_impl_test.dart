import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/data/member_repository_impl.dart';
import 'package:quiz_mobile/layers/data/source/local/member_session_storage.dart';
import 'package:quiz_mobile/layers/data/source/remote/member_api_client.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';
import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

class _FakeApiClient implements MemberApiClient {
  _FakeApiClient({
    this.registerResult,
    this.sessionToken,
    this.meResult,
    this.historyResult,
    this.createAnswerResult,
    this.signInError,
    this.deleteError,
  });

  final PublicMemberDto? registerResult;
  final String? sessionToken;
  final PublicMemberDto? meResult;
  final AnswerHistoryListDto? historyResult;
  final AnswerHistoryEntryDto? createAnswerResult;
  final Object? signInError;
  final Object? deleteError;

  int registerCalls = 0;
  int sessionCalls = 0;
  int meCalls = 0;
  int deleteCalls = 0;
  int historyCalls = 0;
  int createAnswerCalls = 0;
  String? lastToken;

  @override
  Future<PublicMemberDto> registerMember({
    required String handle,
    required String password,
  }) async {
    registerCalls++;
    if (signInError != null) throw signInError!;
    return registerResult!;
  }

  @override
  Future<String> createSession({
    required String handle,
    required String password,
  }) async {
    sessionCalls++;
    if (signInError != null) throw signInError!;
    return sessionToken!;
  }

  @override
  Future<PublicMemberDto> fetchMe({required String token}) async {
    meCalls++;
    lastToken = token;
    return meResult!;
  }

  @override
  Future<void> deleteMe({required String token}) async {
    deleteCalls++;
    lastToken = token;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<AnswerHistoryListDto> listAnswerHistory({
    required String token,
    int? quizId,
    int? limit,
  }) async {
    historyCalls++;
    lastToken = token;
    return historyResult ?? const AnswerHistoryListDto(items: []);
  }

  @override
  Future<AnswerHistoryEntryDto> createAnswer({
    required String token,
    required int quizId,
    required int selectedIndex,
  }) async {
    createAnswerCalls++;
    lastToken = token;
    return createAnswerResult!;
  }

  @override
  void close() {}
}

const _member = PublicMemberDto(
  id: '0192b6f7-4c50-73b1-8b71-11223344aabb',
  handle: 'quiztaker_01',
  hasVerifiedEmail: false,
);

void main() {
  group('MemberRepositoryImpl.signIn', () {
    test('token 取得後に fetchMe を呼び、セッションを保存する', () async {
      final client = _FakeApiClient(sessionToken: 'jwt.token', meResult: _member);
      final storage = InMemoryMemberSessionStorage();
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      final session =
          await repo.signIn(handle: 'quiztaker_01', password: 'correcthorse');

      expect(session.memberId, _member.id);
      expect(session.handle, _member.handle);
      expect(session.token, 'jwt.token');
      expect(client.sessionCalls, 1);
      expect(client.meCalls, 1);
      expect(await storage.read(), session);
    });

    test('signIn が失敗するとストレージは書き換えられない', () async {
      final client = _FakeApiClient(signInError: const MemberParseFailure(message: 'no'));
      final storage = InMemoryMemberSessionStorage();
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      await expectLater(
        repo.signIn(handle: 'x', password: 'y'),
        throwsA(isA<MemberParseFailure>()),
      );
      expect(await storage.read(), isNull);
    });
  });

  group('MemberRepositoryImpl.registerAndSignIn', () {
    test('register 成功後に signIn を実行する', () async {
      final client = _FakeApiClient(
        registerResult: _member,
        sessionToken: 't',
        meResult: _member,
      );
      final storage = InMemoryMemberSessionStorage();
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      await repo.registerAndSignIn(handle: 'quiztaker_01', password: 'correcthorse');

      expect(client.registerCalls, 1);
      expect(client.sessionCalls, 1);
      expect(await storage.read(), isNotNull);
    });
  });

  group('MemberRepositoryImpl.restoreSession', () {
    test('ストレージ内のセッションを返す', () async {
      final client = _FakeApiClient();
      final storage = InMemoryMemberSessionStorage();
      const restored = MemberSession(
        memberId: '00000000-0000-7000-8000-000000000000',
        handle: 'saved',
        token: 't',
      );
      await storage.write(restored);
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      expect(await repo.restoreSession(), restored);
      expect(client.sessionCalls, 0);
    });
  });

  group('MemberRepositoryImpl.signOut / deleteAccount', () {
    test('signOut はローカルセッションのみを破棄する', () async {
      final client = _FakeApiClient();
      final storage = InMemoryMemberSessionStorage();
      const session = MemberSession(memberId: 'x', handle: 'x', token: 't');
      await storage.write(session);
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      await repo.signOut();

      expect(await storage.read(), isNull);
      expect(client.deleteCalls, 0);
    });

    test('deleteAccount はサーバ削除とローカル破棄を両方行う', () async {
      final client = _FakeApiClient();
      final storage = InMemoryMemberSessionStorage();
      const session = MemberSession(memberId: 'x', handle: 'x', token: 't');
      await storage.write(session);
      final repo = MemberRepositoryImpl(client: client, storage: storage);

      await repo.deleteAccount(session);

      expect(client.deleteCalls, 1);
      expect(await storage.read(), isNull);
    });
  });

  group('MemberRepositoryImpl.recordAnswer', () {
    test('token を付けて POST し、DTO を返す', () async {
      final entry = AnswerHistoryEntryDto(
        id: 1,
        quizId: 42,
        selectedIndex: 1,
        isCorrect: true,
        answeredAt: DateTime.utc(2026, 8, 19),
      );
      final client = _FakeApiClient(createAnswerResult: entry);
      final storage = InMemoryMemberSessionStorage();
      final repo = MemberRepositoryImpl(client: client, storage: storage);
      const session = MemberSession(memberId: 'x', handle: 'x', token: 't');

      final result = await repo.recordAnswer(
        session,
        quizId: 42,
        selectedIndex: 1,
      );

      expect(result, entry);
      expect(client.createAnswerCalls, 1);
      expect(client.lastToken, 't');
    });
  });
}
