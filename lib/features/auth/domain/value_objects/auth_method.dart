/// How the current/last authentication happened. Used to decide what to
/// do when the user requests biometric unlock: replay the password call or
/// re-issue a Google sign-in.
enum AuthMethod { password, google }

extension AuthMethodX on AuthMethod {
  String get wire {
    switch (this) {
      case AuthMethod.password: return 'PASSWORD';
      case AuthMethod.google:   return 'GOOGLE';
    }
  }

  static AuthMethod fromWire(String raw) {
    switch (raw) {
      case 'PASSWORD': return AuthMethod.password;
      case 'GOOGLE':   return AuthMethod.google;
      default:
        throw FormatException('Unknown AuthMethod: $raw');
    }
  }
}
