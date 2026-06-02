import 'package:local_auth/local_auth.dart';

import '../../../domain/services/biometric_authenticator.dart';

/// Concrete BiometricAuthenticator backed by `package:local_auth`.
/// Lives in the data layer because it speaks to the platform channels.
class LocalAuthBiometricAdapter implements BiometricAuthenticator {
  final LocalAuthentication _auth;
  LocalAuthBiometricAdapter({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    // We catch EVERYTHING (PlatformException, MissingPluginException,
    // anything else): biometric is a non-essential UX shortcut. A failure
    // here must never break the login flow.
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      // local_auth 3.x: options are top-level named parameters of
      // authenticate(); no AuthenticationOptions wrapper needed.
      return await _auth.authenticate(
        localizedReason: reason,
        // biometricOnly: true rejects device-PIN fallback. We want a
        // real biometric match — otherwise the "shortcut" is just typing
        // the PIN, same UX as typing a password.
        biometricOnly: true,
      );
    } catch (_) {
      // Anything wrong → no auth → caller falls back to manual flow.
      return false;
    }
  }
}
