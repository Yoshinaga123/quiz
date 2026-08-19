import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

/// `GET /api/me` のレスポンスに対応する DTO。
///
/// docs/api/member-api.yaml の `#/components/schemas/PublicMember` と一対一。
/// ADR 0016 §6 により、`password_hash` / `createdAt` / `updatedAt` /
/// `deletedAt` は決してレスポンスに含めない。ここでも strict に検出する。
class PublicMemberDto {
  const PublicMemberDto({
    required this.id,
    required this.handle,
    required this.hasVerifiedEmail,
  });

  final String id;
  final String handle;
  final bool hasVerifiedEmail;

  static const Set<String> _forbiddenFields = {
    'password_hash',
    'passwordHash',
    'created_at',
    'createdAt',
    'updated_at',
    'updatedAt',
    'deleted_at',
    'deletedAt',
    'email',
    'emailVerifiedAt',
    'email_verified_at',
  };

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static final RegExp _handlePattern = RegExp(r'^[a-zA-Z0-9_]+$');

  factory PublicMemberDto.fromJson(Map<String, dynamic> json) {
    for (final field in _forbiddenFields) {
      if (json.containsKey(field)) {
        throw MemberForbiddenFieldFailure(
          field: field,
          message: 'PublicMember must not expose $field (ADR 0016 §6)',
        );
      }
    }

    final id = json['id'];
    if (id is! String || !_uuidPattern.hasMatch(id)) {
      throw const MemberParseFailure(message: 'id must be a UUID string');
    }

    final handle = json['handle'];
    if (handle is! String ||
        handle.length < 3 ||
        handle.length > 32 ||
        !_handlePattern.hasMatch(handle)) {
      throw const MemberParseFailure(
        message: 'handle must match ^[a-zA-Z0-9_]+\$ (3-32 chars)',
      );
    }

    final hasVerifiedEmail = json['hasVerifiedEmail'];
    if (hasVerifiedEmail is! bool) {
      throw const MemberParseFailure(
        message: 'hasVerifiedEmail must be a boolean',
      );
    }

    return PublicMemberDto(
      id: id,
      handle: handle,
      hasVerifiedEmail: hasVerifiedEmail,
    );
  }
}
