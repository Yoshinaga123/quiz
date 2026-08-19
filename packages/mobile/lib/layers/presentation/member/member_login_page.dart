import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/forgot_password_page.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// 実バックエンドに接続する会員向けログイン画面（ADR 0016 / ADR 0017）。
///
/// 既存のモック `LoginPage` (`presentation/auth/login_page.dart`) は
/// 触らず、こちらは Riverpod の `MemberSessionController` を通して
/// `POST /api/session` を叩く。
class MemberLoginPage extends ConsumerStatefulWidget {
  const MemberLoginPage({super.key, this.onRegister});

  final VoidCallback? onRegister;

  @override
  ConsumerState<MemberLoginPage> createState() => _MemberLoginPageState();
}

class _MemberLoginPageState extends ConsumerState<MemberLoginPage> {
  final _handleController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _handleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    try {
      await ref.read(memberSessionControllerProvider.notifier).signIn(
            handle: _handleController.text.trim(),
            password: _passwordController.text,
          );
      final state = ref.read(memberSessionControllerProvider);
      if (state.hasError) {
        setState(() => _errorMessage = state.error?.toString() ?? 'ログインに失敗しました');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberSessionControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('member-login-handle'),
              controller: _handleController,
              decoration: const InputDecoration(labelText: 'ハンドル名'),
              autofillHints: const [AutofillHints.username],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('member-login-password'),
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              key: const Key('member-login-submit'),
              onPressed: isLoading ? null : _submit,
              child: Text(isLoading ? '確認中...' : 'ログイン'),
            ),
            const SizedBox(height: 12),
            if (widget.onRegister != null)
              TextButton(
                onPressed: isLoading ? null : widget.onRegister,
                child: const Text('未登録? 会員登録'),
              ),
            TextButton(
              key: const Key('member-login-forgot-password'),
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      ),
              child: const Text('パスワードを忘れた場合'),
            ),
          ],
        ),
      ),
    );
  }
}
