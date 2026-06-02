import '../../../../../core/network/api_client.dart';
import 'dtos/auth_response_dto.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  const AuthRemoteDataSource(this._apiClient);

  Future<AuthResponseDto> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthResponseDto.fromJson(json);
  }

  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final json = await _apiClient.postJson('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
    return AuthResponseDto.fromJson(json);
  }

  Future<AuthResponseDto> loginWithGoogleIdToken(String idToken) async {
    final json = await _apiClient.postJson(
      '/auth/google/token',
      {'idToken': idToken},
      timeout: const Duration(seconds: 20),
    );
    return AuthResponseDto.fromJson(json);
  }

  Future<AuthResponseDto> refresh(String refreshToken) async {
    final json = await _apiClient.postJson('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return AuthResponseDto.fromJson(json);
  }

  Future<AuthUserDto> me(String accessToken) async {
    final json = await _apiClient.getJson('/auth/me', accessToken: accessToken);
    return AuthUserDto.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<void> logout(String accessToken) async {
    final res = await _apiClient.post('/auth/logout', null, accessToken: accessToken);
    if (res.statusCode == 204 || res.statusCode == 200) return;
    throw _apiClient.decodeError(res);
  }
}
