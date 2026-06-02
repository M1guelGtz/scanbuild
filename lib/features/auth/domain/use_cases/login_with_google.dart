import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository _repository;
  const LoginWithGoogle(this._repository);

  Future<AuthSession?> call() => _repository.loginWithGoogle();
}
