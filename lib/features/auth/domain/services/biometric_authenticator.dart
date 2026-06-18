abstract class BiometricAuthenticator {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String reason});
}
