import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// 会員登録画面。成功すると自動的にログイン状態になる。
class MemberRegisterPage extends ConsumerStatefulWidget {
  const MemberRegisterPage({super.key, this.onSignIn});

  final VoidCallback? onSignIn;

  @override
  ConsumerState<MemberRegisterPage> createState() => _MemberRegisterPageState();
}

class _MemberRegisterPageState extends ConsumerState<MemberRegisterPage> {
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
      await ref
          .read(memberSessionControllerProvider.notifier)
          .registerAndSignIn(
            handle: _handleController.text.trim(),
            password: _passwordController.text,
          );
      final state = ref.read(memberSessionControllerProvider);
      if (state.hasError) {
        setState(() => _errorMessage = state.error?.toString() ?? '登録に失敗しました');
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
      appBar: AppBar(title: const Text('会員登録')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('member-register-handle'),
              controller: _handleController,
              decoration: const InputDecoration(
                labelText: 'ハンドル名',
                helperText: '3-32 文字、英数字と _ のみ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('member-register-password'),
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                helperText: '8-128 文字',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              key: const Key('member-register-submit'),
              onPressed: isLoading ? null : _submit,
              child: Text(isLoading ? '登録中...' : '登録してログイン'),
            ),
            if (widget.onSignIn != null)
              TextButton(
                onPressed: isLoading ? null : widget.onSignIn,
                child: const Text('すでに登録済み'),
              ),
          ],
        ),
      ),
    );
  }
}
