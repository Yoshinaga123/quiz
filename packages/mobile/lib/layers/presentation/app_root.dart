import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/member_login_page.dart';
import 'package:quiz_mobile/layers/presentation/member/member_register_page.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';
import 'package:quiz_mobile/layers/presentation/member/reset_password_page.dart';
import 'package:quiz_mobile/layers/presentation/member/verify_email_page.dart';
import 'package:quiz_mobile/layers/presentation/theme.dart';
import 'package:quiz_mobile/layers/presentation/using_riverpod/list_page/view/quiz_list_page.dart';

/// メール本文の deep link で受け付けるパス。
/// [DeepLinkListener] と [AppRoot._onGenerateRoute] の両方で参照する。
const _kVerifyEmailPath = '/verify-email';
const _kResetPasswordPath = '/reset-password';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    const theme = QuizTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Mobile',
      theme: theme.toThemeData(),
      navigatorKey: navigatorKey,
      home: const _RootRouter(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  /// deep link 用: `/verify-email?token=...` と `/reset-password?token=...`
  /// をシステム / app_links から受けたときに対応する画面を返す。
  static Route<void>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;
    final uri = Uri.tryParse(name);
    if (uri == null) return null;
    final token = uri.queryParameters['token'] ?? '';
    if (uri.path == _kVerifyEmailPath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => VerifyEmailPage(token: token),
      );
    }
    if (uri.path == _kResetPasswordPath) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ResetPasswordPage(token: token),
      );
    }
    return null;
  }
}

class _RootRouter extends ConsumerStatefulWidget {
  const _RootRouter();

  @override
  ConsumerState<_RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends ConsumerState<_RootRouter> {
  bool _showRegister = false;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    unawaited(_initDeepLinks());
  }

  Future<void> _initDeepLinks() async {
    // アプリが停止状態から deep link で起動された場合の初回 URI
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleUri(initialUri);
    } catch (_) {
      // 端末側で受信不可でも UI は継続する。
    }
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    final normalizedPath = uri.path.isEmpty ? '/${uri.host}' : uri.path;
    if (normalizedPath != _kVerifyEmailPath &&
        normalizedPath != _kResetPasswordPath) {
      return;
    }
    // custom scheme (quzzes://reset-password?token=...) の場合は path が空で
    // host に "reset-password" が入るケースがある。両方を吸収したうえで
    // named-route に正規化して push する。
    final routeName = Uri(
      path: normalizedPath,
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
    final navigator = AppRoot.navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(routeName);
  }

  @override
  void dispose() {
    unawaited(_linkSubscription?.cancel());
    super.dispose();
  }

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
