/// 会員セッション（`memberId`, `handle`, `token`）を保持する不変値。
///
/// docs/adr/0016-member-accounts.md §1 に従い、
/// admin JWT とは別鍵で署名された会員向け Bearer トークンを扱う。
class MemberSession {
  const MemberSession({
    required this.memberId,
    required this.handle,
    required this.token,
  });

  final String memberId;
  final String handle;
  final String token;

  MemberSession copyWith({String? memberId, String? handle, String? token}) {
    return MemberSession(
      memberId: memberId ?? this.memberId,
      handle: handle ?? this.handle,
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberSession &&
        other.memberId == memberId &&
        other.handle == handle &&
        other.token == token;
  }

  @override
  int get hashCode => Object.hash(memberId, handle, token);
}
