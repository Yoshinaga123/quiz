import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';

/// 会員セッションのローカル永続化契約。
///
/// 実装は Keychain / EncryptedSharedPreferences ベース（[SecureMemberSessionStorage]）
/// で提供する。テスト時は [InMemoryMemberSessionStorage] を注入する。
abstract class MemberSessionStorage {
  Future<MemberSession?> read();
  Future<void> write(MemberSession session);
  Future<void> clear();
}

class SecureMemberSessionStorage implements MemberSessionStorage {
  SecureMemberSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static const String _key = 'quzzes.member_session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<MemberSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final memberId = decoded['memberId'];
      final handle = decoded['handle'];
      final token = decoded['token'];
      if (memberId is! String ||
          handle is! String ||
          token is! String ||
          memberId.isEmpty ||
          handle.isEmpty ||
          token.isEmpty) {
        return null;
      }
      return MemberSession(memberId: memberId, handle: handle, token: token);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(MemberSession session) {
    return _storage.write(
      key: _key,
      value: jsonEncode({
        'memberId': session.memberId,
        'handle': session.handle,
        'token': session.token,
      }),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// テスト用の in-memory 実装。プロダクションでは使わない。
class InMemoryMemberSessionStorage implements MemberSessionStorage {
  MemberSession? _current;

  @override
  Future<MemberSession?> read() async => _current;

  @override
  Future<void> write(MemberSession session) async {
    _current = session;
  }

  @override
  Future<void> clear() async {
    _current = null;
  }
}
