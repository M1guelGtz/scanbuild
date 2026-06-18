// ignore_for_file: prefer_initializing_formals

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/saved_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/biometric_authenticator.dart';
import '../../domain/services/credentials_vault.dart';
import '../../domain/value_objects/auth_method.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/remote/google_sign_in_service.dart';
import '../local/expired_session_store.dart';
import '../local/token_storage.dart';
import '../mappers/auth_session_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;
  final GoogleSignInService _google;
  final BiometricAuthenticator _biometric;
  final CredentialsVault _vault;
  final ExpiredSessionStore _expiredSessions;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage storage,
    required GoogleSignInService google,
    required BiometricAuthenticator biometric,
    required CredentialsVault vault,
    required ExpiredSessionStore expiredSessions,
  })  : _remote = remote,
        _storage = storage,
        _google = google,
        _biometric = biometric,
        _vault = vault,
        _expiredSessions = expiredSessions;


  @override
  Future<AuthSession> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final dto = await _remote.loginWithPassword(email: email, password: password);
    final session = AuthSessionMapper.toDomain(dto);
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession?> loginWithGoogle() async {
    final idToken = await _google.signInAndGetIdToken();
    if (idToken == null) return null;
    final dto = await _remote.loginWithGoogleIdToken(idToken);
    final session = AuthSessionMapper.toDomain(dto);
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final dto = await _remote.register(email: email, password: password, name: name);
    final session = AuthSessionMapper.toDomain(dto);
    await _persist(session);
    return session;
  }

  @override
  Future<void> logout() async {
    final access = await _storage.readAccessToken();
    try {
      if (access != null) await _remote.logout(access);
    } catch (_) {}
    await _storage.clear();
  }

  @override
  Future<void> expireSessionForInactivity({required Duration idleTimeout}) async {

    final access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    await _expiredSessions.save(
      ExpiredSessionSnapshot(
        accessToken: access,
        refreshToken: refresh,
        expiredAt: DateTime.now(),
        idleTimeout: idleTimeout,
      ),
    );
  
    await logout();
  }

  @override
  Future<AuthUser?> tryRestoreSession() async {
    final access = await _storage.readAccessToken();
    if (access == null) return null;
    try {
      final userDto = await _remote.me(access);
      return AuthSessionMapper.userFromDto(userDto);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final refresh = await _storage.readRefreshToken();
        if (refresh != null) {
          try {
            final dto = await _remote.refresh(refresh);
            final session = AuthSessionMapper.toDomain(dto);
            await _persist(session);
            return session.user;
          } catch (_) {}
        }
      }
      await _storage.clear();
      return null;
    } catch (_) {
      return null;
    }
  }


  @override
  Future<bool> isBiometricUnlockAvailable() async {
    if (!await _vault.hasAny()) return false;
    return _biometric.isAvailable();
  }

  @override
  Future<void> enableBiometricUnlock(SavedCredentials credentials) {
    return _vault.save(credentials);
  }

  @override
  Future<void> disableBiometricUnlock() => _vault.clear();

  @override
  Future<String?> getEnrolledEmail() async {
    final creds = await _vault.read();
    return creds?.email;
  }

  @override
  Future<AuthUser?> loginWithBiometric() async {
    final creds = await _vault.read();
    if (creds == null) return null;

    final ok = await _biometric.authenticate(
      reason: 'Confirma tu identidad para entrar',
    );
    if (!ok) return null;

    switch (creds.method) {
      case AuthMethod.password:
        try {
          final session = await loginWithPassword(
            email: creds.email,
            password: creds.password!,
          );
          return session.user;
        } on ApiException catch (e) {
          if (e.statusCode == 401 || e.statusCode == 403) {
            await _vault.clear();
          }
          rethrow;
        }
      case AuthMethod.google:
        return _googleBiometricCascade();
    }
  }

  Future<AuthUser?> _googleBiometricCascade() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final dto = await _remote.refresh(refreshToken);
        final session = AuthSessionMapper.toDomain(dto);
        await _persist(session);
        return session.user;
      } on ApiException catch (e) {
        if (e.statusCode != 401 && e.statusCode != 403) rethrow;
      }
    }

    final silentIdToken = await _google.trySilentIdToken();
    if (silentIdToken != null) {
      final dto = await _remote.loginWithGoogleIdToken(silentIdToken);
      final session = AuthSessionMapper.toDomain(dto);
      await _persist(session);
      return session.user;
    }

    final fallback = await loginWithGoogle();
    return fallback?.user;
  }


  Future<void> _persist(AuthSession session) async {
    await _storage.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }
}
