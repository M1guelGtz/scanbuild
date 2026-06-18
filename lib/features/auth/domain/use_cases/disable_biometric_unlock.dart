import '../repositories/auth_repository.dart';

class DisableBiometricUnlock {
  final AuthRepository _repository;
  const DisableBiometricUnlock(this._repository);

  Future<void> call() => _repository.disableBiometricUnlock();
}
