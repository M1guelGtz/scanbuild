import 'package:flutter/foundation.dart';

import '../../../../../core/config/dev_config.dart';
import 'auth_remote_data_source.dart';
import 'dtos/auth_response_dto.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource() {
    debugPrint('⚠️  DEV_FAKE_AUTH is ON — using in-memory mock auth backend.');
  }

  static const _latency = Duration(milliseconds: 250);

  AuthUserDto get _user => const AuthUserDto(
        id: DevConfig.fakeUserId,
        email: DevConfig.fakeUserEmail,
        name: DevConfig.fakeUserName,
      );

  AuthResponseDto _session() => AuthResponseDto(
        accessToken: 'dev-access-token',
        refreshToken: 'dev-refresh-token',
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        user: _user,
      );

  @override
  Future<AuthResponseDto> loginWithPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    return _session();
  }

  @override
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future<void>.delayed(_latency);
    return _session();
  }

  @override
  Future<AuthResponseDto> loginWithGoogleIdToken(String idToken) async {
    await Future<void>.delayed(_latency);
    return _session();
  }

  @override
  Future<AuthResponseDto> refresh(String refreshToken) async {
    await Future<void>.delayed(_latency);
    return _session();
  }

  @override
  Future<AuthUserDto> me(String accessToken) async {
    await Future<void>.delayed(_latency);
    return _user;
  }

  @override
  Future<void> logout(String accessToken) async {
    await Future<void>.delayed(_latency);
  }
}
