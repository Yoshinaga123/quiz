import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/view/quiz_details_page.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/notifier/quiz_list_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/notifier/quiz_list_state.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _QuizListView();
  }
}

class _QuizListView extends ConsumerStatefulWidget {
  const _QuizListView();

  @override
  ConsumerState<_QuizListView> createState() => _QuizListViewState();
}

class _QuizListViewState extends ConsumerState<_QuizListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizListStateProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizListStateProvider);
    final theme = Theme.of(context);
    Widget child;

    if (state.status == QuizListStatus.initial ||
        state.status == QuizListStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (state.status == QuizListStatus.failure) {
      child = _FailureView(
        message: state.errorMessage ?? 'Failed to load quizzes.',
        onRetry: () => ref.read(quizListStateProvider.notifier).load(),
      );
    } else {
      child = _Content(quizzes: state.quizzes);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Mobile',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F8FC),
              Color(0xFFE8F1FA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.quizzes,
  });

  final List<Quiz> quizzes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1768AC),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Native Quiz App',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Clean architecture + Riverpod の最小構成です。まずは一覧と詳細の縦切りから始めています。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFD9EAF8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Available Quizzes',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _QuizCard(quiz: quiz);
            },
          ),
        ),
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
  });

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            QuizDetailsPage.route(quizId: quiz.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  quiz.section,
                  style: const TextStyle(
                    color: Color(0xFF1768AC),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                quiz.title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                quiz.question,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: Color(0xFF486581),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quiz.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF486581),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF1768AC),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 56,
            color: Color(0xFFB42318),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
