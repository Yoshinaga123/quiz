import 'package:flutter/material.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';

class QuizQuestionBody extends StatelessWidget {
  const QuizQuestionBody({
    super.key,
    required this.quiz,
    required this.selectedIndex,
    required this.revealed,
    required this.onSelect,
  });

  final Quiz quiz;
  final int? selectedIndex;
  final bool revealed;
  final ValueChanged<int> onSelect;

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
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.question,
                  style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFD9E2EC)),
                ),
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
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
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
                    variant: resolveOptionVariant(
                      index: i,
                      selectedIndex: selectedIndex,
                      correctIndex: quiz.correctAnswerIndex,
                      revealed: revealed,
                    ),
                    onTap: revealed ? null : () => onSelect(i),
                  ),
                  if (i != quiz.options.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        if (revealed && selectedIndex != null) ...[
          const SizedBox(height: 16),
          _Feedback(quiz: quiz, selectedIndex: selectedIndex!),
        ],
      ],
    );
  }
}

enum OptionVariant { idle, selected, correct, incorrect, revealCorrect }

OptionVariant resolveOptionVariant({
  required int index,
  required int? selectedIndex,
  required int correctIndex,
  required bool revealed,
}) {
  if (!revealed) {
    return selectedIndex == index ? OptionVariant.selected : OptionVariant.idle;
  }
  if (index == correctIndex && selectedIndex == index) return OptionVariant.correct;
  if (index == selectedIndex) return OptionVariant.incorrect;
  if (index == correctIndex) return OptionVariant.revealCorrect;
  return OptionVariant.idle;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final String text;
  final OptionVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, badge, showCheck) = switch (variant) {
      OptionVariant.idle => (
          const Color(0xFFF8FBFD),
          const Color(0xFFD9E2EC),
          const Color(0xFFBCCCDC),
          false,
        ),
      OptionVariant.selected => (
          const Color(0xFFE3F2FD),
          const Color(0xFF1768AC),
          const Color(0xFF1768AC),
          false,
        ),
      OptionVariant.correct || OptionVariant.revealCorrect => (
          const Color(0xFFE6F4EA),
          const Color(0xFF2D8A4F),
          const Color(0xFF2D8A4F),
          true,
        ),
      OptionVariant.incorrect => (
          const Color(0xFFFDECEA),
          const Color(0xFFB42318),
          const Color(0xFFB42318),
          false,
        ),
    };

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: badge,
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
              if (showCheck) ...[
                const SizedBox(width: 12),
                const Icon(Icons.check_circle, color: Color(0xFF2D8A4F)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.quiz,
    required this.selectedIndex,
  });

  final Quiz quiz;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final correct = isAnswerCorrect(quiz, selectedIndex);
    return Card(
      color: correct ? const Color(0xFFE6F4EA) : const Color(0xFFFDECEA),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? '正解' : '不正解',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: correct ? const Color(0xFF2D8A4F) : const Color(0xFFB42318),
              ),
            ),
            const SizedBox(height: 8),
            Text(quiz.explanation),
            const SizedBox(height: 8),
            Text(
              '出典: ${quiz.source}',
              style: const TextStyle(color: Color(0xFF486581)),
            ),
          ],
        ),
      ),
    );
  }
}
