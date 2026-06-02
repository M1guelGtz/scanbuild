import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/email.dart';

class LoginWithPassword {
  final AuthRepository _repository;
  const LoginWithPassword(this._repository);

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    final validEmail = Email.create(email);
    return _repository.loginWithPassword(
      email: validEmail.value,
      password: password,
    );
  }
}
