import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/data/service/local_notification_service.dart';
import 'package:quiz_mobile/layers/data/service/push_feed_poller.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';
import 'package:quiz_mobile/layers/presentation/member/member_profile_page.dart';
import 'package:quiz_mobile/layers/domain/quiz_session.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/details_page/view/quiz_details_page.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/history_page/view/history_page.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/notifier/quiz_list_notifier.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/notifier/quiz_list_state.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/play_page/view/quiz_play_page.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/remote_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final LocalNotificationService _notificationService =
      LocalNotificationService();
  PushFeedPoller? _pushFeedPoller;
  bool _isCheckingPushFeed = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizListStateProvider.notifier).load();
      _initializePushMock();
    });
  }

  Future<void> _initializePushMock() async {
    await _notificationService.initialize(
      onTap: (quizId) {
        if (!mounted) return;
        Navigator.of(context).push(QuizDetailsPage.route(quizId: quizId));
      },
    );

    final preferences = await SharedPreferences.getInstance();
    _pushFeedPoller = PushFeedPoller(
      apiClient: ref.read(quizApiClientProvider),
      notificationService: _notificationService,
      preferences: preferences,
    );
    await _checkPushFeed(showResult: false);
  }

  Future<void> _checkPushFeed({required bool showResult}) async {
    final poller = _pushFeedPoller;
    if (poller == null || _isCheckingPushFeed) return;

    setState(() {
      _isCheckingPushFeed = true;
    });

    try {
      final feed = await poller.checkLatest();
      if (!mounted || !showResult) return;
      final message = feed == null
          ? 'mock Push はまだありません。'
          : '最新 mock Push を確認しました: ${feed.title}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } on QuizFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('mock Push の確認に失敗しました: ${failure.message ?? failure}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPushFeed = false;
        });
      }
    }
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
        actions: [
          IconButton(
            tooltip: '履歴',
            onPressed: () {
              Navigator.of(context).push(HistoryPage.route());
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'mock Push を確認',
            onPressed: _isCheckingPushFeed
                ? null
                : () => _checkPushFeed(showResult: true),
            icon: const Icon(Icons.notifications_active_outlined),
          ),
          IconButton(
            key: const Key('quiz-list-profile'),
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

class _Content extends StatefulWidget {
  const _Content({
    required this.quizzes,
  });

  final List<Quiz> quizzes;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  String? _sectionFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = widget.quizzes.map((quiz) => quiz.section).toSet().toList()
      ..sort();
    final visible = filterBySection(widget.quizzes, _sectionFilter);

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
                '選んで回答してから正解と解説が出ます。履歴は端末に残ります。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFD9EAF8),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: visible.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).push(
                          QuizPlayPage.route(
                            quizzes: widget.quizzes,
                            sectionFilter: _sectionFilter,
                          ),
                        );
                      },
                child: Text(
                  _sectionFilter == null
                      ? '$defaultPlayLimit問出題する'
                      : '$_sectionFilter を出題する',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('すべて'),
                selected: _sectionFilter == null,
                onSelected: (_) {
                  setState(() {
                    _sectionFilter = null;
                  });
                },
              ),
              for (final section in sections) ...[
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(section),
                  selected: _sectionFilter == section,
                  onSelected: (_) {
                    setState(() {
                      _sectionFilter = section;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Available Quizzes',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = visible[index];
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
            QuizPlayPage.route(
              quizzes: [quiz],
              sectionFilter: quiz.section,
              limit: 1,
            ),
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
