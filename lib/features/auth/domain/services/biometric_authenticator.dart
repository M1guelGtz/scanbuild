/// Outbound port: hardware-level biometric authentication.
///
/// The domain only cares whether the user "is who they say they are" right
/// now (a boolean local check). Whether the device uses fingerprint, face,
/// iris, or device passcode fallback is an implementation detail of the
/// adapter in the infrastructure layer.
abstract class BiometricAuthenticator {
  /// Returns true if the device has biometric hardware AND the user has
  /// enrolled at least one credential (e.g. registered a fingerprint).
  Future<bool> isAvailable();

  /// Triggers the OS biometric prompt. Returns true on success, false on
  /// user cancellation or failed verification. Should NEVER throw on
  /// cancellation — only on configuration errors.
  Future<bool> authenticate({required String reason});
}
