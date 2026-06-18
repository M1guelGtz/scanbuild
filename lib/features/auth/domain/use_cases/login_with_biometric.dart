import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginWithBiometric {
  final AuthRepository _repository;
  const LoginWithBiometric(this._repository);

  Future<AuthUser?> call() => _repository.loginWithBiometric();
}
