import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Orchestrates the quick-unlock flow:
///   1. Prompt the OS biometric.
///   2. If accepted, read the saved credentials.
///   3. Replay the original login call (password or google).
///
/// The single entry point keeps the ViewModel ignorant of the steps. If
/// the user cancels the prompt or there are no saved credentials, returns
/// `null` so the UI knows to fall back to the manual login form.
class LoginWithBiometric {
  final AuthRepository _repository;
  const LoginWithBiometric(this._repository);

  Future<AuthUser?> call() => _repository.loginWithBiometric();
}
