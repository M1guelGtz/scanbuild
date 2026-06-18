import '../value_objects/auth_method.dart';

class SavedCredentials {
  final AuthMethod method;
  final String email;
  final String? password;

  const SavedCredentials._({
    required this.method,
    required this.email,
    this.password,
  });

  factory SavedCredentials.password({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) {
      throw const FormatException('email cannot be empty');
    }
    if (password.isEmpty) {
      throw const FormatException('password cannot be empty');
    }
    return SavedCredentials._(
      method: AuthMethod.password,
      email: email.trim(),
      password: password,
    );
  }

  factory SavedCredentials.google({required String email}) {
    return SavedCredentials._(
      method: AuthMethod.google,
      email: email.trim(),
    );
  }
}
