import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/member/providers.dart';

/// ADR 0018 §3: メール検証トークンを消費する画面。
///
/// メール内リンクからディープリンクで到達する想定。token は path parameter
/// として受け取る。成功で 204、失敗で 400（期限切れ / 消費済み / 不正）。
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    try {
      await ref
          .read(memberRepositoryProvider)
          .consumeEmailVerification(token: widget.token);
      if (!mounted) return;
      setState(() {
        _isSuccess = true;
        _isVerifying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メールアドレスの検証')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isVerifying) const CircularProgressIndicator(),
              if (_isSuccess)
                const Text(
                  'メールアドレスの検証が完了しました。',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              if (_errorMessage != null)
                Text(
                  '検証に失敗しました。リンクの有効期限が切れているか、'
                  '既に使用済みの可能性があります。\n$_errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
