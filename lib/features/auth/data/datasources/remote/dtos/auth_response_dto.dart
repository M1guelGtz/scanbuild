/// Pure JSON shape returned by the auth-service. Lives in `data/` and
/// never escapes the boundary as-is — a mapper turns it into an
/// `AuthSession` (domain entity) before reaching the application layer.
class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final String? refreshExpiresAt;
  final AuthUserDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.refreshExpiresAt,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      refreshExpiresAt: json['refreshExpiresAt'] as String?,
      user: AuthUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthUserDto {
  final String id;
  final String email;
  final String name;

  const AuthUserDto({required this.id, required this.email, required this.name});

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}
