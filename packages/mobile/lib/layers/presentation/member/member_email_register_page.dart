import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// ADR 0018 §3: メールアドレス登録画面。会員向け Bearer が必要。
class MemberEmailRegisterPage extends ConsumerStatefulWidget {
  const MemberEmailRegisterPage({super.key, required this.session});

  final MemberSession session;

  @override
  ConsumerState<MemberEmailRegisterPage> createState() =>
      _MemberEmailRegisterPageState();
}

class _MemberEmailRegisterPageState
    extends ConsumerState<MemberEmailRegisterPage> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _noticeMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _noticeMessage = null;
      _isSubmitting = true;
    });
    try {
      await ref.read(memberRepositoryProvider).setEmail(
            widget.session,
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _noticeMessage =
            '確認メールを送信しました（24時間有効）。受信ボックスをご確認ください。';
        _emailController.clear();
      });
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
      appBar: AppBar(title: const Text('メールアドレス登録')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'パスワードを忘れたときに再設定リンクを送るために利用します。'
              'email は他の会員には公開されません。',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('member-email-input'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (_noticeMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_noticeMessage!,
                    style: const TextStyle(color: Colors.green)),
              ),
            FilledButton(
              key: const Key('member-email-submit'),
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? '送信中...' : '確認メールを送信'),
            ),
          ],
        ),
      ),
    );
  }
}
