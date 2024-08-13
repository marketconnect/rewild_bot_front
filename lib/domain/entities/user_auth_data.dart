// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserAuthData {
  final String token;
  final int expiredAt;
  final bool freebie;
  const UserAuthData({
    required this.token,
    required this.freebie,
    required this.expiredAt,
  });

  @override
  String toString() =>
      'UserAuthData(token: $token, expiredAt: $expiredAt, freebie: $freebie)';
}
