import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_page/notifier/history_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_page/notifier/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HistoryPage());
  }

  @override
  Widget build(BuildContext context) {
    return const _HistoryView();
  }
}

class _HistoryView extends ConsumerStatefulWidget {
  const _HistoryView();

  @override
  ConsumerState<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<_HistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyStateProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyStateProvider);
    final theme = Theme.of(context);
    final records = state.records;
    final totalQuestions = records.fold<int>(0, (sum, record) => sum + record.total);
    final totalCorrect = records.fold<int>(0, (sum, record) => sum + record.correct);
    final accuracy = calculateAccuracy(totalCorrect, totalQuestions);

    Widget child;
    if (state.status == HistoryStatus.initial || state.status == HistoryStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (state.status == HistoryStatus.failure) {
      child = Center(child: Text(state.errorMessage ?? '履歴を読み込めませんでした。'));
    } else if (records.isEmpty) {
      child = const Center(child: Text('まだ履歴がありません。出題して記録してください。'));
    } else {
      child = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('これまでの挑戦', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('挑戦 ${records.length} 回 ・ $totalCorrect / $totalQuestions 問正解 ・ 累計 $accuracy%'),
                  const SizedBox(height: 8),
                  const Text(
                    '履歴は端末内（shared_preferences）にあります。データを消すと失われます。',
                    style: TextStyle(color: Color(0xFF486581)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final record in records)
            Card(
              child: ListTile(
                title: Text('${record.correct} / ${record.total} 問正解'),
                subtitle: Text(
                  '${record.sectionFilter ?? 'すべて'} ・ ${record.completedAt}',
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        actions: [
          if (records.isNotEmpty)
            IconButton(
              tooltip: '履歴を消す',
              onPressed: () => ref.read(historyStateProvider.notifier).clear(),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F8FC), Color(0xFFE8F1FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
