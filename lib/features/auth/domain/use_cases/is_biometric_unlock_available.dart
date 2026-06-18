import '../repositories/auth_repository.dart';

class IsBiometricUnlockAvailable {
  final AuthRepository _repository;
  const IsBiometricUnlockAvailable(this._repository);

  Future<bool> call() => _repository.isBiometricUnlockAvailable();
}
