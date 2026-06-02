import '../value_objects/auth_method.dart';

/// What we persist after a successful login so a subsequent biometric
/// unlock can replay it. Two shapes:
///   - PASSWORD: stores email + plaintext password (encrypted at rest by
///     the OS-provided secure storage).
///   - GOOGLE: stores only the method + email hint (no password possible).
///     On biometric unlock, the Google SDK is invoked again and will reuse
///     the device's Google account session if still authorized.
class SavedCredentials {
  final AuthMethod method;
  final String email;
  final String? password; // only set when method == password

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
