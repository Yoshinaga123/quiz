import 'package:flutter/material.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/service/rank.dart';

/// 会員プロフィール画面（ADR 0016 PR-E スコープ）。
///
/// HTTP 統合は次段（別 PR）。この widget は DTO を受け取って描画するだけの
/// stateless 表示部で、Riverpod・auth トークン管理には触れない。
class MemberProfileView extends StatelessWidget {
  const MemberProfileView({
    super.key,
    required this.member,
    required this.history,
    this.onLogout,
    this.onDeleteAccount,
    this.onOpenEmailRegister,
    this.rank,
  });

  final PublicMemberDto member;
  final List<AnswerHistoryEntryDto> history;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onOpenEmailRegister;
  final RankResult? rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${member.handle} さん'),
        actions: [
          if (onOpenEmailRegister != null)
            IconButton(
              key: const Key('member-profile-email-register'),
              tooltip: 'メールアドレス登録',
              onPressed: onOpenEmailRegister,
              icon: Icon(
                member.hasVerifiedEmail
                    ? Icons.mark_email_read
                    : Icons.mail_outline,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('会員 ID', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  SelectableText(
                    member.id,
                    key: const Key('member-profile-id'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (rank != null) ...[
            const SizedBox(height: 16),
            _RankCard(rank: rank!),
          ],
          const SizedBox(height: 16),
          Text('回答履歴', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('まだ回答がありません。', style: theme.textTheme.bodyMedium),
            )
          else
            ...history.map(_HistoryTile.new),
          const SizedBox(height: 24),
          if (onLogout != null)
            OutlinedButton(
              key: const Key('member-profile-logout'),
              onPressed: onLogout,
              child: const Text('ログアウト'),
            ),
          const SizedBox(height: 8),
          if (onDeleteAccount != null)
            OutlinedButton(
              key: const Key('member-profile-delete'),
              onPressed: onDeleteAccount,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('退会する'),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry);

  final AnswerHistoryEntryDto entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Quiz #${entry.quizId}'),
        subtitle: Text(
          '選択: ${entry.selectedIndex} / ${entry.answeredAt.toLocal()}',
        ),
        trailing: Text(
          entry.isCorrect ? '正解' : '不正解',
          style: TextStyle(
            color: entry.isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank});

  final RankResult rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('現在の段位', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              rank.rank,
              key: const Key('member-profile-rank'),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: rank.progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 8),
            Text(
              '習熟度: ${rank.mastery} / ${rank.totalPossible} pt '
              '(${(rank.progress * 100).round()}%)',
              style: theme.textTheme.bodySmall,
            ),
            if (rank.nextRank != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '次の段位「${rank.nextRank}」まで +${rank.toNextRank} pt',
                  style: theme.textTheme.bodySmall,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('最高位「名人」到達',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
