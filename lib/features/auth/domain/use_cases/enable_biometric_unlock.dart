import '../entities/saved_credentials.dart';
import '../repositories/auth_repository.dart';

class EnableBiometricUnlock {
  final AuthRepository _repository;
  const EnableBiometricUnlock(this._repository);

  Future<void> call(SavedCredentials credentials) {
    return _repository.enableBiometricUnlock(credentials);
  }
}
