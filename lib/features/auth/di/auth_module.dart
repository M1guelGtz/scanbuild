import '../../../core/config/dev_config.dart';
import '../../../core/network/api_client.dart';
import '../data/datasources/local/local_auth_biometric_adapter.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/remote/fake_auth_remote_data_source.dart';
import '../data/datasources/remote/google_sign_in_service.dart';
import '../data/local/credentials_vault_impl.dart';
import '../data/local/expired_session_store.dart';
import '../data/local/token_storage.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/services/biometric_authenticator.dart';
import '../domain/services/credentials_vault.dart';
import '../domain/use_cases/disable_biometric_unlock.dart';
import '../domain/use_cases/enable_biometric_unlock.dart';
import '../domain/use_cases/expire_session_for_inactivity.dart';
import '../domain/use_cases/get_enrolled_email.dart';
import '../domain/use_cases/is_biometric_unlock_available.dart';
import '../domain/use_cases/login_with_biometric.dart';
import '../domain/use_cases/login_with_google.dart';
import '../domain/use_cases/login_with_password.dart';
import '../domain/use_cases/logout.dart';
import '../domain/use_cases/register_user.dart';
import '../domain/use_cases/try_restore_session.dart';
import '../presentation/view_models/home_view_model.dart';
import '../presentation/view_models/integrity_view_model.dart';
import '../presentation/view_models/login_view_model.dart';
import '../presentation/view_models/register_view_model.dart';

/// Manual factory / composition root for the auth feature.
class AuthModule {
  // Long-lived adapters
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final GoogleSignInService googleSignIn;
  final BiometricAuthenticator biometricAuthenticator;
  final CredentialsVault credentialsVault;
  final AuthRepository repository;

  // Use cases
  final LoginWithPassword loginWithPasswordUseCase;
  final LoginWithGoogle loginWithGoogleUseCase;
  final RegisterUser registerUserUseCase;
  final Logout logoutUseCase;
  final ExpireSessionForInactivity expireSessionForInactivityUseCase;
  final TryRestoreSession tryRestoreSessionUseCase;
  final IsBiometricUnlockAvailable isBiometricUnlockAvailableUseCase;
  final EnableBiometricUnlock enableBiometricUnlockUseCase;
  final DisableBiometricUnlock disableBiometricUnlockUseCase;
  final LoginWithBiometric loginWithBiometricUseCase;
  final GetEnrolledEmail getEnrolledEmailUseCase;

  AuthModule._({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.googleSignIn,
    required this.biometricAuthenticator,
    required this.credentialsVault,
    required this.repository,
    required this.loginWithPasswordUseCase,
    required this.loginWithGoogleUseCase,
    required this.registerUserUseCase,
    required this.logoutUseCase,
    required this.expireSessionForInactivityUseCase,
    required this.tryRestoreSessionUseCase,
    required this.isBiometricUnlockAvailableUseCase,
    required this.enableBiometricUnlockUseCase,
    required this.disableBiometricUnlockUseCase,
    required this.loginWithBiometricUseCase,
    required this.getEnrolledEmailUseCase,
  });

  factory AuthModule.create({required ApiClient apiClient}) {
    final AuthRemoteDataSource remote = DevConfig.useFakeAuth
        ? FakeAuthRemoteDataSource()
        : AuthRemoteDataSource(apiClient);
    final storage = TokenStorage();
    final google = GoogleSignInService();
    final BiometricAuthenticator biometric = LocalAuthBiometricAdapter();
    final CredentialsVault vault = CredentialsVaultImpl();
    final expiredSessions = ExpiredSessionStore();
    final AuthRepository repo = AuthRepositoryImpl(
      remote: remote,
      storage: storage,
      google: google,
      biometric: biometric,
      vault: vault,
      expiredSessions: expiredSessions,
    );
    return AuthModule._(
      remoteDataSource: remote,
      tokenStorage: storage,
      googleSignIn: google,
      biometricAuthenticator: biometric,
      credentialsVault: vault,
      repository: repo,
      loginWithPasswordUseCase: LoginWithPassword(repo),
      loginWithGoogleUseCase: LoginWithGoogle(repo),
      registerUserUseCase: RegisterUser(repo),
      logoutUseCase: Logout(repo),
      expireSessionForInactivityUseCase: ExpireSessionForInactivity(repo),
      tryRestoreSessionUseCase: TryRestoreSession(repo),
      isBiometricUnlockAvailableUseCase: IsBiometricUnlockAvailable(repo),
      enableBiometricUnlockUseCase: EnableBiometricUnlock(repo),
      disableBiometricUnlockUseCase: DisableBiometricUnlock(repo),
      loginWithBiometricUseCase: LoginWithBiometric(repo),
      getEnrolledEmailUseCase: GetEnrolledEmail(repo),
    );
  }



  LoginViewModel loginViewModelFactory() => LoginViewModel(
        loginWithPassword: loginWithPasswordUseCase,
        loginWithGoogle: loginWithGoogleUseCase,
        isBiometricUnlockAvailable: isBiometricUnlockAvailableUseCase,
        enableBiometricUnlock: enableBiometricUnlockUseCase,
        loginWithBiometric: loginWithBiometricUseCase,
        getEnrolledEmail: getEnrolledEmailUseCase,
        biometricAuthenticator: biometricAuthenticator,
      );

  IntegrityViewModel integrityViewModelFactory() => IntegrityViewModel();

  HomeViewModel homeViewModelFactory() => HomeViewModel(logoutUseCase);

  RegisterViewModel registerViewModelFactory() => RegisterViewModel(
        registerUser: registerUserUseCase,
        loginWithGoogle: loginWithGoogleUseCase,
      );
}
