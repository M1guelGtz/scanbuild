import '../entities/saved_credentials.dart';
import '../repositories/auth_repository.dart';

/// Stores the credentials the user just used to authenticate so a future
/// biometric prompt can replay the login without re-typing.
///
/// Called by the LoginViewModel right after a successful login, when the
/// user opts in to "enable quick unlock with fingerprint/face".
class EnableBiometricUnlock {
  final AuthRepository _repository;
  const EnableBiometricUnlock(this._repository);

  Future<void> call(SavedCredentials credentials) {
    return _repository.enableBiometricUnlock(credentials);
  }
}
