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

  // ---------- Login flows ----------

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
    } catch (_) {/* best-effort; we still wipe local state */}
    await _storage.clear();
    // Sign-out semantics (intentional, requested by the product):
    //   - Backend session is revoked above (we asked /auth/logout).
    //   - Local access/refresh tokens are wiped (storage.clear).
    //   - BUT the biometric vault and the Google SDK session are PRESERVED
    //     so the user can come back in with one tap of their fingerprint
    //     without retyping credentials or picking a Google account.
    //
    // If the user wants to fully forget the device, they call
    // disableBiometricUnlock() (e.g. from a future "Olvidarme en este
    // dispositivo" toggle). That use case still exists and wipes the vault.
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
          } catch (_) {/* fall through */}
        }
      }
      await _storage.clear();
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------- Biometric quick unlock ----------

  @override
  Future<bool> isBiometricUnlockAvailable() async {
    // Cheap checks first to short-circuit and not even ask the SO if we
    // know there's nothing stored.
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
          // Password rotated elsewhere, account locked, etc. Stale
          // credentials are useless — wipe the shortcut so the user
          // re-enrolls next time.
          if (e.statusCode == 401 || e.statusCode == 403) {
            await _vault.clear();
          }
          rethrow;
        }
      case AuthMethod.google:
        // For Google we DON'T re-open the account picker. We follow a
        // three-step cascade so the user gets the smoothest possible flow:
        //
        //   1. /auth/refresh with the stored refreshToken (instant, no UI).
        //   2. Lightweight Google sign-in (no picker if Google session is
        //      still authorized on the device).
        //   3. As a last resort, the full Google picker.
        //
        // Steps 1+2 cover the vast majority of cases within the 7-day
        // lifetime of the refresh token. Step 3 only kicks in after a
        // revocation or a wipe of the Google app data.
        return _googleBiometricCascade();
    }
  }

  /// Implements the three-step cascade described in [loginWithBiometric]
  /// for the Google branch.
  Future<AuthUser?> _googleBiometricCascade() async {
    // Step 1: try refreshing our own backend session — no Google at all.
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final dto = await _remote.refresh(refreshToken);
        final session = AuthSessionMapper.toDomain(dto);
        await _persist(session);
        return session.user;
      } on ApiException catch (e) {
        // Anything other than 401/403 is unexpected — bubble up.
        if (e.statusCode != 401 && e.statusCode != 403) rethrow;
        // 401/403 → token expired or revoked; fall through to Step 2.
      }
    }

    // Step 2: silent Google. No UI shown if the device still has an
    // authorized Google session for this app.
    final silentIdToken = await _google.trySilentIdToken();
    if (silentIdToken != null) {
      final dto = await _remote.loginWithGoogleIdToken(silentIdToken);
      final session = AuthSessionMapper.toDomain(dto);
      await _persist(session);
      return session.user;
    }

    // Step 3: last resort — interactive picker. Rare path; only happens
    // when the user fully revoked the Google authorization or cleared
    // app data.
    final fallback = await loginWithGoogle();
    return fallback?.user;
  }

  // ---------- helpers ----------

  Future<void> _persist(AuthSession session) async {
    await _storage.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }
}
