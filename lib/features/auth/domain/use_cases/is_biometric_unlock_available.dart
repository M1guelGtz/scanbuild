import '../repositories/auth_repository.dart';

/// Returns true only when ALL three conditions hold simultaneously:
///   1. The device has biometric hardware AND an enrolled biometric.
///   2. The user previously opted-in (a saved credentials record exists).
///   3. We have credentials stored to replay.
///
/// The repository is the single source of truth that combines hardware
/// availability + storage state.
class IsBiometricUnlockAvailable {
  final AuthRepository _repository;
  const IsBiometricUnlockAvailable(this._repository);

  Future<bool> call() => _repository.isBiometricUnlockAvailable();
}
