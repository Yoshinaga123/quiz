import 'package:flutter/material.dart';

const _verificationMessage =
    'quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。';
const _mockVerificationCode = '123456';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _codeSent = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _requestCode() {
    setState(() {
      _errorMessage = null;
    });

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'ユーザー名とパスワードを入力してください';
      });
      return;
    }

    setState(() {
      _codeSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('確認コードを送信しました (デモコード: 123456)')),
    );
  }

  Future<void> _verifyAndLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (_codeController.text.isEmpty) {
      setState(() {
        _errorMessage = '確認コードを入力してください';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (_codeController.text.trim() != _mockVerificationCode) {
      setState(() {
        _isProcessing = false;
        _errorMessage = '確認コードが正しくありません';
      });
      return;
    }

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Quiz Mobile',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _verificationMessage,
                      style: const TextStyle(color: Color(0xFF0F4C81)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFF7A271A)),
                        ),
                      ),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'ユーザー名',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_codeSent,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'パスワード',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: !_codeSent,
                    ),
                    const SizedBox(height: 16),
                    if (_codeSent)
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: '確認コード',
                          hintText: '123456',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : _codeSent
                              ? _verifyAndLogin
                              : _requestCode,
                      child: Text(
                        _isProcessing
                            ? '処理中...'
                            : _codeSent
                                ? '確認してログイン'
                                : '確認コードを送信',
                      ),
                    ),
                    if (_codeSent)
                      TextButton(
                        onPressed: _isProcessing ? null : _requestCode,
                        child: const Text('確認コードを再送'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
