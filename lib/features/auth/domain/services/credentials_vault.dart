import '../entities/saved_credentials.dart';

/// Outbound port: encrypted-at-rest persistence of the user's credentials,
/// kept alive across app launches so biometric unlock can re-issue the
/// login call.
///
/// The infrastructure adapter is responsible for choosing the storage
/// backend (Keystore-backed on Android, Keychain on iOS via the
/// `flutter_secure_storage` plugin).
abstract class CredentialsVault {
  Future<void> save(SavedCredentials credentials);
  Future<SavedCredentials?> read();
  Future<bool> hasAny();
  Future<void> clear();
}
