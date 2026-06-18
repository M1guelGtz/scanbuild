// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/saved_credentials.dart';
import '../../domain/services/biometric_authenticator.dart';
import '../../domain/use_cases/enable_biometric_unlock.dart';
import '../../domain/use_cases/get_enrolled_email.dart';
import '../../domain/use_cases/is_biometric_unlock_available.dart';
import '../../domain/use_cases/login_with_biometric.dart';
import '../../domain/use_cases/login_with_google.dart';
import '../../domain/use_cases/login_with_password.dart';
import 'login_state.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginWithPassword _loginWithPassword;
  final LoginWithGoogle _loginWithGoogle;
  final IsBiometricUnlockAvailable _isBiometricUnlockAvailable;
  final EnableBiometricUnlock _enableBiometricUnlock;
  final LoginWithBiometric _loginWithBiometric;
  final GetEnrolledEmail _getEnrolledEmail;
  final BiometricAuthenticator _biometricAuthenticator;

  LoginState _state = const LoginState();
  LoginState get state => _state;

  SavedCredentials? _pendingCredentials;

  LoginViewModel({
    required LoginWithPassword loginWithPassword,
    required LoginWithGoogle loginWithGoogle,
    required IsBiometricUnlockAvailable isBiometricUnlockAvailable,
    required EnableBiometricUnlock enableBiometricUnlock,
    required LoginWithBiometric loginWithBiometric,
    required GetEnrolledEmail getEnrolledEmail,
    required BiometricAuthenticator biometricAuthenticator,
  })  : _loginWithPassword = loginWithPassword,
        _loginWithGoogle = loginWithGoogle,
        _isBiometricUnlockAvailable = isBiometricUnlockAvailable,
        _enableBiometricUnlock = enableBiometricUnlock,
        _loginWithBiometric = loginWithBiometric,
        _getEnrolledEmail = getEnrolledEmail,
        _biometricAuthenticator = biometricAuthenticator;


  Future<void> resolveBiometricAvailability() async {
    try {
      final ok = await _isBiometricUnlockAvailable();
      _set(_state.copyWith(biometricAvailable: ok));
    } catch (e, st) {
      debugPrint('resolveBiometricAvailability failed (non-fatal): $e\n$st');
      _set(_state.copyWith(biometricAvailable: false));
    }
  }


  Future<bool> loginWithPassword({
    required String email,
    required String password,
  }) async {
    if (_state.isBusy) return false;
    _set(_state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _loginWithPassword(email: email, password: password);
      _pendingCredentials = SavedCredentials.password(
        email: email,
        password: password,
      );
      await _maybeOfferEnroll();
      return true;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: _humanize(e)));
      return false;
    } on FormatException catch (e) {
      _set(_state.copyWith(errorMessage: e.message));
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo iniciar sesión. Revisa tu conexión.'));
      return false;
    } finally {
      _set(_state.copyWith(isSubmitting: false));
    }
  }


  Future<bool> loginWithGoogle() async {
    if (_state.isBusy) return false;
    _set(_state.copyWith(isGoogleLoading: true, errorMessage: null));
    try {
      final session = await _loginWithGoogle();
      if (session == null) return false;
      _pendingCredentials = SavedCredentials.google(email: session.user.email);
      await _maybeOfferEnroll();
      return true;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: _humanize(e)));
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo iniciar sesión con Google.'));
      return false;
    } finally {
      _set(_state.copyWith(isGoogleLoading: false));
    }
  }


  Future<bool> loginWithBiometric() async {
    if (_state.isBusy) return false;
    _set(_state.copyWith(isBiometricLoading: true, errorMessage: null));
    try {
      final user = await _loginWithBiometric();
      return user != null;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: _humanize(e)));
      if (e.statusCode == 401 || e.statusCode == 403) {
        await resolveBiometricAvailability();
      }
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo verificar la huella.'));
      return false;
    } finally {
      _set(_state.copyWith(isBiometricLoading: false));
    }
  }

  Future<void> acceptBiometricEnroll() async {
    final creds = _pendingCredentials;
    _pendingCredentials = null;
    _set(_state.copyWith(shouldOfferBiometricEnroll: false));
    if (creds == null) return;
    final granted = await _biometricAuthenticator.authenticate(
      reason: 'Activa el acceso rápido con huella',
    );
    if (!granted) return;
    await _enableBiometricUnlock(creds);
  }

  void declineBiometricEnroll() {
    _pendingCredentials = null;
    _set(_state.copyWith(shouldOfferBiometricEnroll: false));
  }


  void setKeepSession(bool value) {
    _set(_state.copyWith(keepSession: value));
  }

  void clearError() {
    if (_state.errorMessage != null) _set(_state.copyWith(errorMessage: null));
  }

  Future<void> _maybeOfferEnroll() async {
    try {
      final hwOk = await _biometricAuthenticator.isAvailable();
      if (!hwOk) {
        _pendingCredentials = null;
        return;
      }
      final enrolledEmail = await _getEnrolledEmail();
      final currentEmail = _pendingCredentials?.email;
      final differentAccount =
          enrolledEmail != null && currentEmail != null && enrolledEmail != currentEmail;
      final nothingEnrolled = enrolledEmail == null;
      if (nothingEnrolled || differentAccount) {
        _set(_state.copyWith(shouldOfferBiometricEnroll: true));
        return;
      }
    } catch (e, st) {
      debugPrint('Biometric availability check failed (non-fatal): $e\n$st');
    }
    _pendingCredentials = null;
  }

  void _set(LoginState next) {
    _state = next;
    notifyListeners();
  }

  String _humanize(ApiException e) {
    switch (e.code) {
      case 'AUTH_ERROR':
        return 'Correo o contraseña incorrectos.';
      case 'CONFLICT':
        return 'El correo ya está registrado.';
      case 'VALIDATION_ERROR':
        return e.message;
      default:
        return e.message;
    }
  }

  @override
  void dispose() {
    _pendingCredentials = null;
    super.dispose();
  }
}
