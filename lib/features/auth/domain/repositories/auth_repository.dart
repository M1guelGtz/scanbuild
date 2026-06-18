import '../entities/auth_session.dart';
import '../entities/auth_user.dart';
import '../entities/saved_credentials.dart';

abstract class AuthRepository {
  Future<AuthSession> loginWithPassword({
    required String email,
    required String password,
  });
  Future<AuthSession?> loginWithGoogle();
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<AuthUser?> tryRestoreSession();

  Future<void> expireSessionForInactivity({required Duration idleTimeout});


  Future<bool> isBiometricUnlockAvailable();

  Future<void> enableBiometricUnlock(SavedCredentials credentials);

  Future<void> disableBiometricUnlock();

  Future<String?> getEnrolledEmail();

  Future<AuthUser?> loginWithBiometric();
}
