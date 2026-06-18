import '../entities/saved_credentials.dart';

abstract class CredentialsVault {
  Future<void> save(SavedCredentials credentials);
  Future<SavedCredentials?> read();
  Future<bool> hasAny();
  Future<void> clear();
}
