import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/source/local/member_session_storage.dart';
import 'package:quiz_mobile/layers/domain/entity/member_session.dart';

void main() {
  group('InMemoryMemberSessionStorage', () {
    test('read は最初 null を返す', () async {
      final storage = InMemoryMemberSessionStorage();
      expect(await storage.read(), isNull);
    });

    test('write と read が往復する', () async {
      final storage = InMemoryMemberSessionStorage();
      const session = MemberSession(
        memberId: '0192b6f7-4c50-73b1-8b71-11223344aabb',
        handle: 'quiztaker_01',
        token: 'jwt.token',
      );
      await storage.write(session);
      expect(await storage.read(), session);
    });

    test('clear で消える', () async {
      final storage = InMemoryMemberSessionStorage();
      const session = MemberSession(memberId: 'x', handle: 'x', token: 't');
      await storage.write(session);
      await storage.clear();
      expect(await storage.read(), isNull);
    });
  });

  group('MemberSession', () {
    test('値等価性が成立する', () {
      const a = MemberSession(memberId: 'x', handle: 'h', token: 't');
      const b = MemberSession(memberId: 'x', handle: 'h', token: 't');
      const c = MemberSession(memberId: 'x', handle: 'h', token: 'other');
      expect(a, b);
      expect(a == c, isFalse);
      expect(a.hashCode, b.hashCode);
    });
  });
}
