import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_page/view/history_page.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/notifier/quiz_play_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/notifier/quiz_play_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/widgets/quiz_question_body.dart';

class QuizPlayPage extends StatelessWidget {
  const QuizPlayPage({
    super.key,
    required this.quizzes,
    this.sectionFilter,
    this.limit = defaultPlayLimit,
  });

  final List<Quiz> quizzes;
  final String? sectionFilter;
  final int limit;

  static Route<void> route({
    required List<Quiz> quizzes,
    String? sectionFilter,
    int limit = defaultPlayLimit,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => QuizPlayPage(
        quizzes: quizzes,
        sectionFilter: sectionFilter,
        limit: limit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _QuizPlayView(
      quizzes: quizzes,
      sectionFilter: sectionFilter,
      limit: limit,
    );
  }
}

class _QuizPlayView extends ConsumerStatefulWidget {
  const _QuizPlayView({
    required this.quizzes,
    required this.sectionFilter,
    required this.limit,
  });

  final List<Quiz> quizzes;
  final String? sectionFilter;
  final int limit;

  @override
  ConsumerState<_QuizPlayView> createState() => _QuizPlayViewState();
}

class _QuizPlayViewState extends ConsumerState<_QuizPlayView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizPlayStateProvider.notifier).start(
            quizzes: widget.quizzes,
            sectionFilter: widget.sectionFilter,
            limit: widget.limit,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizPlayStateProvider);
    final theme = Theme.of(context);

    if (state.status == QuizPlayStatus.finished && state.completedRecord != null) {
      final record = state.completedRecord!;
      final accuracy = calculateAccuracy(record.correct, record.total);
      return Scaffold(
        appBar: AppBar(title: const Text('結果')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${record.correct} / ${record.total} 問正解',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('正答率 $accuracy% ・ セクション: ${record.sectionFilter ?? 'すべて'}'),
              const SizedBox(height: 12),
              const Text('履歴は端末内に保存されます。アプリのデータを消すと失われます。'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(HistoryPage.route());
                },
                child: const Text('履歴を見る'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('一覧へ戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final quiz = state.currentQuiz;
    Widget child;
    if (state.status == QuizPlayStatus.empty) {
      child = const Center(child: Text('出題できる問題がありません。'));
    } else if (quiz == null) {
      child = const Center(child: CircularProgressIndicator());
    } else {
      child = Column(
        children: [
          LinearProgressIndicator(
            value: state.quizIds.isEmpty
                ? 0
                : (state.currentIndex + (state.revealed ? 1 : 0)) / state.quizIds.length,
          ),
          Expanded(
            child: QuizQuestionBody(
              quiz: quiz,
              selectedIndex: state.selectedIndex,
              revealed: state.revealed,
              onSelect: ref.read(quizPlayStateProvider.notifier).select,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.revealed
                      ? () => ref.read(quizPlayStateProvider.notifier).next()
                      : state.selectedIndex == null
                          ? null
                          : () => ref.read(quizPlayStateProvider.notifier).submit(),
                  child: Text(
                    state.revealed
                        ? (state.isLast ? '結果を見る' : '次の問題へ')
                        : '回答する',
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          quiz == null
              ? '出題'
              : '${state.currentIndex + 1} / ${state.quizIds.length}',
        ),
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
