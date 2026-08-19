import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// ADR 0018 §3: パスワード再設定画面。token は path parameter として受け取る。
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.token,
    this.onSuccess,
  });

  final String token;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  bool _isDone = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });
    final newPassword = _newPasswordController.text;
    if (newPassword != _confirmController.text) {
      setState(() =>
          _errorMessage = '新しいパスワードと確認用パスワードが一致しません');
      return;
    }
    if (newPassword.length < 8 || newPassword.length > 128) {
      setState(() => _errorMessage = 'パスワードは 8-128 文字で入力してください');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(memberRepositoryProvider).consumePasswordReset(
            token: widget.token,
            newPassword: newPassword,
          );
      if (!mounted) return;
      setState(() => _isDone = true);
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('パスワードの再設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('reset-password-new'),
              controller: _newPasswordController,
              decoration:
                  const InputDecoration(labelText: '新しいパスワード（8-128 文字）'),
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('reset-password-confirm'),
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'パスワード（確認用）'),
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (_isDone)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'パスワードを再設定しました。新しいパスワードでログインしてください。',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            FilledButton(
              key: const Key('reset-password-submit'),
              onPressed: _isSubmitting || _isDone ? null : _submit,
              child: Text(_isSubmitting ? '更新中...' : 'パスワードを更新'),
            ),
          ],
        ),
      ),
    );
  }
}
