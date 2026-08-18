import 'package:flutter/material.dart';
import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';

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
  });

  final PublicMemberDto member;
  final List<AnswerHistoryEntryDto> history;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${member.handle} さん')),
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
