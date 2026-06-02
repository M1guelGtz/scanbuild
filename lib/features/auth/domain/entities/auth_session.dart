import 'auth_user.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime? refreshExpiresAt;
  final AuthUser user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.refreshExpiresAt,
  });
}
