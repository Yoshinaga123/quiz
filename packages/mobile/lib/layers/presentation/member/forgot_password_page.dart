import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// ADR 0018 §3: パスワード忘却時にリセットリンク送信を要求する画面。
///
/// バックエンドは列挙対策のため常に 202 を返す。UI もそれに合わせ、
/// 実在有無を示さない「送信済み」表示のみ返す。
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      await ref.read(memberRepositoryProvider).requestPasswordReset(
            handleOrEmail: _controller.text.trim(),
          );
      if (!mounted) return;
      setState(() => _isSubmitted = true);
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
      appBar: AppBar(title: const Text('パスワードを忘れた場合')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '登録済みのメールアドレスまたはハンドル名を入力してください。'
              '検証済み email がある場合のみ、再設定用のリンクを送信します。',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('forgot-password-input'),
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: 'ハンドル名 または email'),
              autofillHints: const [AutofillHints.username],
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (_isSubmitted)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '送信を受け付けました。該当する検証済みメールがあれば、'
                  '30 分以内に再設定リンクが届きます。',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            FilledButton(
              key: const Key('forgot-password-submit'),
              onPressed: _isSubmitting || _isSubmitted ? null : _submit,
              child: Text(_isSubmitting ? '送信中...' : '再設定リンクを送信'),
            ),
          ],
        ),
      ),
    );
  }
}
