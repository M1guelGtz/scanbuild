import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/email.dart';
import '../value_objects/password.dart';

class RegisterUser {
  final AuthRepository _repository;
  const RegisterUser(this._repository);

  Future<AuthSession> call({
    required String email,
    required String password,
    required String name,
  }) {
    final validEmail = Email.create(email);
    final validPassword = Password.create(password);
    if (name.trim().isEmpty) {
      throw const FormatException('El nombre no puede estar vacío');
    }
    return _repository.register(
      email: validEmail.value,
      password: validPassword.value,
      name: name.trim(),
    );
  }
}
