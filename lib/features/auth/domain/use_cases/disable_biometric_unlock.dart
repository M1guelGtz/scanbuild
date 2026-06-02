import '../repositories/auth_repository.dart';

/// Wipes saved credentials. Called when the user explicitly disables the
/// shortcut or, more commonly, as part of the logout flow so that signing
/// out always means "go through the full login next time".
class DisableBiometricUnlock {
  final AuthRepository _repository;
  const DisableBiometricUnlock(this._repository);

  Future<void> call() => _repository.disableBiometricUnlock();
}
