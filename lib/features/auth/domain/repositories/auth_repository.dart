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

  /// Closes the session because the user went idle. Before wiping the live
  /// token pair it persists a snapshot (tokens + the idle window that was in
  /// effect) into encrypted storage. [idleTimeout] is the configured window
  /// that elapsed without interaction.
  Future<void> expireSessionForInactivity({required Duration idleTimeout});

  // ---------- Biometric quick-unlock ----------

  /// True only when (a) device has biometric hardware + enrolled biometric
  /// AND (b) the user has previously opted-in (credentials are stored).
  Future<bool> isBiometricUnlockAvailable();

  /// Persists the credentials the user just used to authenticate. Should
  /// be invoked right after a successful login, when the user opts in.
  Future<void> enableBiometricUnlock(SavedCredentials credentials);

  /// Removes stored credentials. Logout does NOT call this anymore (we
  /// preserve the shortcut across logouts); this method is reserved for
  /// an explicit "forget me on this device" toggle.
  Future<void> disableBiometricUnlock();

  /// Returns the email of the account currently enrolled for biometric
  /// quick-unlock, or `null` if nothing is stored. Used by the LoginPage
  /// to decide whether to re-offer the "Activar acceso rápido" dialog to
  /// a user whose email does not match the one already enrolled.
  Future<String?> getEnrolledEmail();

  /// Full biometric-unlock flow:
  ///   1. OS prompt
  ///   2. read credentials
  ///   3. replay the original login (password call or Google sign-in).
  ///
  /// Returns `null` if the user cancels the prompt or there are no stored
  /// credentials; throws on API errors.
  Future<AuthUser?> loginWithBiometric();
}
