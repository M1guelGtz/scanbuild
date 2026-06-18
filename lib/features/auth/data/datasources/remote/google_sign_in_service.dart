import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/config/api_config.dart';

class GoogleSignInService {
  static bool _initialized = false;

  GoogleSignInService();

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConfig.googleWebClientId,
    );
    _initialized = true;
  }

  Future<String?> signInAndGetIdToken() async {
    await ensureInitialized();
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

  Future<String?> trySilentIdToken() async {
    await ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) return null;
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      return idToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }
}
