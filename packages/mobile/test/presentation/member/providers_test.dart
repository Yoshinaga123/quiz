import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/mastery_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';
import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';
import 'package:quiz_mobile/layers/domain/repository/member_repository.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

class _FakeRepository implements MemberRepository {
  _FakeRepository({this.restored, this.signInError});

  MemberSession? restored;
  Object? signInError;

  int signOutCalls = 0;
  int deleteCalls = 0;
  MemberSession? signedInAs;

  @override
  Future<MemberSession?> restoreSession() async => restored;

  @override
  Future<MemberSession> registerAndSignIn({
    required String handle,
    required String password,
  }) {
    return signIn(handle: handle, password: password);
  }

  @override
  Future<MemberSession> signIn({
    required String handle,
    required String password,
  }) async {
    if (signInError != null) throw signInError!;
    final session = MemberSession(
      memberId: '00000000-0000-7000-8000-000000000000',
      handle: handle,
      token: 'fake.$handle.token',
    );
    signedInAs = session;
    return session;
  }

  @override
  Future<PublicMemberDto> fetchMe(MemberSession session) async {
    return PublicMemberDto(
      id: session.memberId,
      handle: session.handle,
      hasVerifiedEmail: false,
    );
  }

  @override
  Future<List<AnswerHistoryEntryDto>> fetchAnswerHistory(
    MemberSession session, {
    int? quizId,
    int? limit,
  }) async {
    return const [];
  }

  @override
  Future<AnswerHistoryEntryDto> recordAnswer(
    MemberSession session, {
    required int quizId,
    required int selectedIndex,
  }) async {
    return AnswerHistoryEntryDto(
      id: 1,
      quizId: quizId,
      selectedIndex: selectedIndex,
      isCorrect: false,
      answeredAt: DateTime.utc(2026, 8, 19),
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<void> deleteAccount(MemberSession session) async {
    deleteCalls++;
  }

  @override
  Future<MasteryResponseDto> fetchMastery(MemberSession session) async {
    return const MasteryResponseDto(items: [], streakCap: 0);
  }

  @override
  Future<void> setEmail(MemberSession session, {required String email}) async {}

  @override
  Future<void> consumeEmailVerification({required String token}) async {}

  @override
  Future<void> requestPasswordReset({required String handleOrEmail}) async {}

  @override
  Future<void> consumePasswordReset({
    required String token,
    required String newPassword,
  }) async {}
}

ProviderContainer _containerWith(MemberRepository repo) {
  final container = ProviderContainer(
    overrides: [memberRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('MemberSessionController', () {
    test('build は restoreSession の結果を返す', () async {
      final repo = _FakeRepository(
        restored: const MemberSession(
          memberId: 'x',
          handle: 'saved',
          token: 't',
        ),
      );
      final container = _containerWith(repo);

      final session = await container.read(memberSessionControllerProvider.future);
      expect(session?.handle, 'saved');
    });

    test('signIn は state を成功セッションで更新する', () async {
      final repo = _FakeRepository();
      final container = _containerWith(repo);
      await container.read(memberSessionControllerProvider.future);

      await container
          .read(memberSessionControllerProvider.notifier)
          .signIn(handle: 'quiztaker_01', password: 'correcthorse');

      final state = container.read(memberSessionControllerProvider);
      expect(state.value?.handle, 'quiztaker_01');
      expect(state.hasError, isFalse);
    });

    test('signIn が失敗すると state はエラー状態になる', () async {
      final repo = _FakeRepository(
        signInError: const MemberParseFailure(message: 'nope'),
      );
      final container = _containerWith(repo);
      await container.read(memberSessionControllerProvider.future);

      await container
          .read(memberSessionControllerProvider.notifier)
          .signIn(handle: 'x', password: 'y');

      final state = container.read(memberSessionControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('signOut はリポジトリを呼び state を null に戻す', () async {
      final repo = _FakeRepository(
        restored: const MemberSession(memberId: 'x', handle: 'x', token: 't'),
      );
      final container = _containerWith(repo);
      await container.read(memberSessionControllerProvider.future);

      await container.read(memberSessionControllerProvider.notifier).signOut();

      expect(repo.signOutCalls, 1);
      expect(container.read(memberSessionControllerProvider).value, isNull);
    });

    test('deleteAccount はリポジトリを呼び state を null に戻す', () async {
      final repo = _FakeRepository(
        restored: const MemberSession(memberId: 'x', handle: 'x', token: 't'),
      );
      final container = _containerWith(repo);
      await container.read(memberSessionControllerProvider.future);

      await container
          .read(memberSessionControllerProvider.notifier)
          .deleteAccount();

      expect(repo.deleteCalls, 1);
      expect(container.read(memberSessionControllerProvider).value, isNull);
    });
  });
}
