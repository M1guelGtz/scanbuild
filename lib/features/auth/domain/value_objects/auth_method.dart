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
