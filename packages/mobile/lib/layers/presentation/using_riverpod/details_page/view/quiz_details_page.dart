import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/notifier/quiz_details_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/notifier/quiz_details_state.dart';

class QuizDetailsPage extends StatelessWidget {
  const QuizDetailsPage({
    super.key,
    required this.quizId,
  });

  final int quizId;

  static Route<void> route({required int quizId}) {
    return MaterialPageRoute<void>(
      builder: (_) => QuizDetailsPage(quizId: quizId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _QuizDetailsView(quizId: quizId);
  }
}

class _QuizDetailsView extends ConsumerStatefulWidget {
  const _QuizDetailsView({
    required this.quizId,
  });

  final int quizId;

  @override
  ConsumerState<_QuizDetailsView> createState() => _QuizDetailsViewState();
}

class _QuizDetailsViewState extends ConsumerState<_QuizDetailsView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizDetailsStateProvider.notifier).load(id: widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizDetailsStateProvider);
    final theme = Theme.of(context);
    Widget child;

    if (state.status == QuizDetailsStatus.initial ||
        state.status == QuizDetailsStatus.loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (state.status == QuizDetailsStatus.failure) {
      child = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Failed to load quiz details.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.read(quizDetailsStateProvider.notifier).load(id: widget.quizId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      child = _Content(quiz: state.quiz!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Details',
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
    required this.quiz,
  });

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        Card(
          color: const Color(0xFF102A43),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1768AC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    quiz.section,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  quiz.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.question,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFD9E2EC),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choices', style: theme.textTheme.titleLarge),
                const SizedBox(height: 14),
                for (var i = 0; i < quiz.options.length; i++) ...[
                  _OptionTile(
                    label: '${i + 1}',
                    text: quiz.options[i],
                    isCorrect: i == quiz.correctAnswerIndex,
                  ),
                  if (i != quiz.options.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explanation', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(quiz.explanation, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Source', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(quiz.source, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        if (quiz.code != null && quiz.code!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF0B1F33),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      quiz.code!,
                      style: const TextStyle(
                        color: Color(0xFFD9E2EC),
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.isCorrect,
  });

  final String label;
  final String text;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE6F4EA) : const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFF2D8A4F) : const Color(0xFFD9E2EC),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect ? const Color(0xFF2D8A4F) : const Color(0xFFBCCCDC),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Color(0xFF243B53),
              ),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 12),
            const Icon(
              Icons.check_circle,
              color: Color(0xFF2D8A4F),
            ),
          ],
        ],
      ),
    );
  }
}
