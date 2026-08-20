import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/history_record.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/presentation/member/member_profile_page.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/notifier/quiz_details_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/notifier/quiz_details_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_providers.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/widgets/quiz_question_body.dart';

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
  int? _selectedIndex;
  bool _revealed = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizDetailsStateProvider.notifier).load(id: widget.quizId);
    });
  }

  Future<void> _submit(Quiz quiz) async {
    final selected = _selectedIndex;
    if (selected == null || _revealed) return;
    setState(() {
      _revealed = true;
    });
    if (_saved) return;
    _saved = true;
    final startedAt = nowIso();
    await ref.read(appendHistoryRecordProvider)(
      HistoryRecord(
        id: generateSessionId(),
        sectionFilter: quiz.section,
        total: 1,
        correct: isAnswerCorrect(quiz, selected) ? 1 : 0,
        startedAt: startedAt,
        completedAt: nowIso(),
        answers: [
          QuizAnswer(
            quizId: quiz.id,
            selectedIndex: selected,
            correct: isAnswerCorrect(quiz, selected),
          ),
        ],
      ),
    );
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
      final quiz = state.quiz!;
      child = Column(
        children: [
          Expanded(
            child: QuizQuestionBody(
              quiz: quiz,
              selectedIndex: _selectedIndex,
              revealed: _revealed,
              onSelect: (index) {
                if (_revealed) return;
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _revealed || _selectedIndex == null
                      ? null
                      : () => _submit(quiz),
                  child: Text(_revealed ? '回答済み' : '回答する'),
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
          '出題',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            key: const Key('quiz-details-profile'),
            tooltip: 'プロフィール',
            onPressed: () =>
                Navigator.of(context).push(MemberProfilePage.route()),
            icon: const Icon(Icons.person_outline),
          ),
        ],
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
