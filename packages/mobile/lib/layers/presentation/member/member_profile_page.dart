import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/mastery_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/service/rank.dart';
import 'package:quiz_mobile/layers/presentation/member/member_email_register_page.dart';
import 'package:quiz_mobile/layers/presentation/member/member_profile_view.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// [MemberProfileView] を Riverpod セッションから駆動するコンテナ。
///
/// - 起動時に `/api/me` と `/api/me/answers` を並列で叩く
/// - AppBar の「メール登録」ボタンから [MemberEmailRegisterPage] へ遷移
/// - ログアウト / 退会は [MemberSessionController] へ委譲
class MemberProfilePage extends ConsumerStatefulWidget {
  const MemberProfilePage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MemberProfilePage());

  @override
  ConsumerState<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends ConsumerState<MemberProfilePage> {
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final session = ref.read(memberSessionControllerProvider).value;
    if (session == null) {
      throw StateError('member session is required to view the profile');
    }
    final repo = ref.read(memberRepositoryProvider);
    final results = await Future.wait([
      repo.fetchMe(session),
      repo.fetchAnswerHistory(session, limit: 20),
    ]);
    return _ProfileData(
      member: results[0] as PublicMemberDto,
      history: results[1] as List<AnswerHistoryEntryDto>,
    );
  }

  Future<void> _openEmailRegister() async {
    final session = ref.read(memberSessionControllerProvider).value;
    if (session == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MemberEmailRegisterPage(session: session),
      ),
    );
    if (!mounted) return;
    setState(() => _future = _load());
  }

  Future<void> _logout() async {
    await ref.read(memberSessionControllerProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退会の確認'),
        content: const Text(
          '本当に退会しますか? 履歴も併せて削除されます。この操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('退会する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(memberSessionControllerProvider.notifier).deleteAccount();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final masteryAsync = ref.watch(memberMasteryProvider);
    return FutureBuilder<_ProfileData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('プロフィール')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '読み込みに失敗しました\n${snapshot.error ?? ''}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        final rank = _resolveRank(masteryAsync.value, data.history);
        return MemberProfileView(
          member: data.member,
          history: data.history,
          rank: rank,
          onOpenEmailRegister: () => unawaited(_openEmailRegister()),
          onLogout: () => unawaited(_logout()),
          onDeleteAccount: () => unawaited(_deleteAccount()),
        );
      },
    );
  }
}

RankResult? _resolveRank(
  MasteryResponseDto? mastery,
  List<AnswerHistoryEntryDto> history,
) {
  if (mastery == null) return null;
  final streaks = <int, int>{};
  for (final entry in mastery.items) {
    streaks[entry.quizId] = entry.streak;
  }
  // クイズカタログを別途取らないため、streak に登場する quizId + 履歴の quizId を
  // 集計対象として計算する。全カタログを取れる仕組みができたらそちらに置き換える。
  final ids = <int>{};
  ids.addAll(streaks.keys);
  for (final entry in history) {
    ids.add(entry.quizId);
  }
  final sorted = ids.toList()..sort();
  return computeRank(streaks, sorted);
}

class _ProfileData {
  const _ProfileData({required this.member, required this.history});

  final PublicMemberDto member;
  final List<AnswerHistoryEntryDto> history;
}
