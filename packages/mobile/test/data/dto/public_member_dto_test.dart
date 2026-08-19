import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

Map<String, dynamic> _loadFixture(String name) {
  final candidates = [
    File('../../docs/api/fixtures/$name'),
    File('docs/api/fixtures/$name'),
  ];
  for (final file in candidates) {
    if (file.existsSync()) {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  throw StateError('docs/api/fixtures/$name not found');
}

void main() {
  group('PublicMemberDto.fromJson', () {
    test('fixtures/member-self.json をパースできる', () {
      final dto = PublicMemberDto.fromJson(_loadFixture('member-self.json'));

      expect(dto.id, '0192b6f7-4c50-73b1-8b71-11223344aabb');
      expect(dto.handle, 'quiztaker_01');
    });

    test('password_hash が含まれていたら MemberForbiddenFieldFailure', () {
      final json = Map<String, dynamic>.from(_loadFixture('member-self.json'))
        ..['password_hash'] = 'bcrypt\$...';
      expect(
        () => PublicMemberDto.fromJson(json),
        throwsA(
          isA<MemberForbiddenFieldFailure>().having(
            (e) => e.field,
            'field',
            'password_hash',
          ),
        ),
      );
    });

    test('createdAt が含まれていたら MemberForbiddenFieldFailure', () {
      final json = Map<String, dynamic>.from(_loadFixture('member-self.json'))
        ..['createdAt'] = '2026-08-18T00:00:00.000Z';
      expect(
        () => PublicMemberDto.fromJson(json),
        throwsA(isA<MemberForbiddenFieldFailure>()),
      );
    });

    test('id が UUID 形式でないと MemberParseFailure', () {
      final json = Map<String, dynamic>.from(_loadFixture('member-self.json'))
        ..['id'] = 'not-a-uuid';
      expect(
        () => PublicMemberDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });

    test('handle に許可外の文字が入ると MemberParseFailure', () {
      final json = Map<String, dynamic>.from(_loadFixture('member-self.json'))
        ..['handle'] = 'space name';
      expect(
        () => PublicMemberDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });

    test('handle が 3 文字未満だと MemberParseFailure', () {
      final json = Map<String, dynamic>.from(_loadFixture('member-self.json'))
        ..['handle'] = 'ab';
      expect(
        () => PublicMemberDto.fromJson(json),
        throwsA(isA<MemberParseFailure>()),
      );
    });
  });
}
