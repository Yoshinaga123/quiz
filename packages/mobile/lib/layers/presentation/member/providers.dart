import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/dto/mastery_dto.dart';
import 'package:quiz_mobile/layers/data/member_repository_impl.dart';
import 'package:quiz_mobile/layers/data/source/local/member_session_storage.dart';
import 'package:quiz_mobile/layers/data/source/remote/member_api_client.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';
import 'package:quiz_mobile/layers/domain/repository/member_repository.dart';

/// 会員 API クライアント（依存性注入用）。テスト時は override してモックを注入する。
final memberApiClientProvider = Provider<MemberApiClient>((ref) {
  final client = MemberApiClient();
  ref.onDispose(client.close);
  return client;
});

final memberSessionStorageProvider = Provider<MemberSessionStorage>((ref) {
  return SecureMemberSessionStorage();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepositoryImpl(
    client: ref.watch(memberApiClientProvider),
    storage: ref.watch(memberSessionStorageProvider),
  );
});

/// アプリ全体で参照される「現在ログイン中のセッション」。
///
/// `AsyncNotifier` で保持し、起動時にストレージから復元、
/// サインイン/サインアウト操作でも更新する。
class MemberSessionController extends AsyncNotifier<MemberSession?> {
  @override
  Future<MemberSession?> build() {
    return ref.read(memberRepositoryProvider).restoreSession();
  }

  Future<void> signIn({
    required String handle,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(memberRepositoryProvider).signIn(
            handle: handle,
            password: password,
          );
    });
  }

  Future<void> registerAndSignIn({
    required String handle,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(memberRepositoryProvider).registerAndSignIn(
            handle: handle,
            password: password,
          );
    });
  }

  Future<void> signOut() async {
    await ref.read(memberRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> deleteAccount() async {
    final session = state.value;
    if (session == null) return;
    await ref.read(memberRepositoryProvider).deleteAccount(session);
    state = const AsyncData(null);
  }
}

final memberSessionControllerProvider =
    AsyncNotifierProvider<MemberSessionController, MemberSession?>(
  MemberSessionController.new,
);

/// ADR 0018 系のフォローアップ: サーバー由来 mastery (streak マップ)。
///
/// セッションが確立していないとき、または fetch に失敗したときは
/// `AsyncValue.data(null)` を返す。UI 側で null を「未取得/取得失敗」として扱う。
final memberMasteryProvider = FutureProvider<MasteryResponseDto?>((ref) async {
  final sessionState = ref.watch(memberSessionControllerProvider);
  final session = sessionState.value;
  if (session == null) return null;
  try {
    return await ref.read(memberRepositoryProvider).fetchMastery(session);
  } catch (_) {
    return null;
  }
});
