import 'dart:io';

/// API + OAuth configuration.
///
/// Both values can be overridden at build time with --dart-define so the
/// repo stays free of environment-specific secrets:
///
///   flutter run \
///     --dart-define=API_BASE_URL=https://api.tu-dominio.com \
///     --dart-define=GOOGLE_WEB_CLIENT_ID=12345-abc.apps.googleusercontent.com
///
/// Defaults are tuned for local development against the auth-service
/// running on the host machine.
class ApiConfig {
  /// Resolves the base URL for the backend depending on the platform.
  ///
  /// - Android emulator: `10.0.2.2` is the alias the emulator uses to reach
  ///   the host machine's localhost.
  /// - Everything else (iOS sim, desktop, web): plain `localhost`.
  /// - Physical Android device on the same Wi-Fi: pass --dart-define with
  ///   your machine's LAN IP, e.g. http://192.168.1.50:3000.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Base URL of the projects-service. Same emulator-alias rules as above.
  /// Defaults to :3001 because auth-service occupies :3000.
  static String get projectsBaseUrl {
    const fromEnv = String.fromEnvironment('PROJECTS_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://10.0.2.2:3001';
    return 'http://localhost:3001';
  }

  /// Web OAuth client_id of the backend. The Flutter app uses it as
  /// `serverClientId` so the resulting id_token's `aud` matches what the
  /// backend expects when calling /auth/google/token.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '285029488152-4feqohbgh4i5vhe1qqjhsokrbj6fi3bn.apps.googleusercontent.com',
  );
}
