import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/member_login_page.dart';
import 'package:quiz_mobile/layers/presentation/member/member_register_page.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';
import 'package:quiz_mobile/layers/presentation/theme.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/view/quiz_list_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = QuizTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Mobile',
      theme: theme.toThemeData(),
      home: const _RootRouter(),
    );
  }
}

class _RootRouter extends ConsumerStatefulWidget {
  const _RootRouter();

  @override
  ConsumerState<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends ConsumerState<_RootRouter> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(memberSessionControllerProvider);

    return sessionState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _authSurface(),
      data: (session) => session != null ? const QuizListPage() : _authSurface(),
    );
  }

  Widget _authSurface() {
    return _showRegister
        ? MemberRegisterPage(onSignIn: () => setState(() => _showRegister = false))
        : MemberLoginPage(onRegister: () => setState(() => _showRegister = true));
  }
}
