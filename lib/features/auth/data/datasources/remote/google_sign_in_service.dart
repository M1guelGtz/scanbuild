import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/config/api_config.dart';

/// Wraps `google_sign_in` v7. The rest of the app only sees two operations:
///   - [signInAndGetIdToken]: interactive picker (used in the manual
///     "Continuar con Google" button).
///   - [trySilentIdToken]: lightweight attempt with NO UI — used during
///     the biometric quick-unlock path so the user is not interrupted by
///     the account picker if their Google session is still authorized.
class GoogleSignInService {
  static bool _initialized = false;

  GoogleSignInService();

  /// Idempotent — safe to call multiple times.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConfig.googleWebClientId,
    );
    _initialized = true;
  }

  /// Picker-driven sign-in. Returns idToken on success, null if the user
  /// cancels the picker.
  Future<String?> signInAndGetIdToken() async {
    await ensureInitialized();
    // Force-show the picker so the user can pick / switch account.
    await GoogleSignIn.instance.signOut();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google did not return an idToken (verify SHA-1 + package name in Cloud Console)',
      );
    }
    return idToken;
  }

  /// Tries to re-issue an idToken without showing any UI. Used by the
  /// biometric quick-unlock path. Returns null if the SDK cannot resolve
  /// the account silently (e.g. user revoked access, signed out, or never
  /// logged in on this device). The caller must then fall back to the
  /// picker flow or surface an error.
  Future<String?> trySilentIdToken() async {
    await ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) return null;
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      return idToken;
    } catch (_) {
      // Any failure is treated as "cannot resolve silently". The caller
      // decides what to do next.
      return null;
    }
  }

  Future<void> signOut() async {
    await ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }
}
