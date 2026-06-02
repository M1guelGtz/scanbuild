import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../datasources/remote/dtos/auth_response_dto.dart';

class AuthSessionMapper {
  const AuthSessionMapper._();

  static AuthSession toDomain(AuthResponseDto dto) {
    return AuthSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      refreshExpiresAt: dto.refreshExpiresAt == null
          ? null
          : DateTime.tryParse(dto.refreshExpiresAt!),
      user: AuthUser(
        id: dto.user.id,
        email: dto.user.email,
        name: dto.user.name,
      ),
    );
  }

  static AuthUser userFromDto(AuthUserDto dto) =>
      AuthUser(id: dto.id, email: dto.email, name: dto.name);
}
