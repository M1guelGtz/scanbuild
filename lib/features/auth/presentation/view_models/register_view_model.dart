// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/use_cases/login_with_google.dart';
import '../../domain/use_cases/register_user.dart';
import 'register_state.dart';

/// Drives the RegisterPage with two side-effect actions:
///
/// - [register] for the email/password flow → POST /auth/register
/// - [registerWithGoogle] for the native sign-in flow → POST
///   /auth/google/token (the backend upserts the user, so the same use
///   case used for "login with Google" doubles as registration).
class RegisterViewModel extends ChangeNotifier {
  final RegisterUser _registerUser;
  final LoginWithGoogle _loginWithGoogle;

  RegisterState _state = const RegisterState();
  RegisterState get state => _state;

  RegisterViewModel({
    required RegisterUser registerUser,
    required LoginWithGoogle loginWithGoogle,
  })  : _registerUser = registerUser,
        _loginWithGoogle = loginWithGoogle;

  void setAcceptedTerms(bool value) {
    _set(_state.copyWith(acceptedTerms: value));
  }

  void clearError() {
    if (_state.errorMessage != null) _set(_state.copyWith(errorMessage: null));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_state.isBusy) return false;
    if (!_state.acceptedTerms) {
      _set(_state.copyWith(errorMessage: 'Acepta los términos para continuar.'));
      return false;
    }
    _set(_state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _registerUser(email: email, password: password, name: name);
      return true;
    } on FormatException catch (e) {
      _set(_state.copyWith(errorMessage: e.message));
      return false;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: _humanize(e)));
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo crear la cuenta. Revisa tu conexión.'));
      return false;
    } finally {
      _set(_state.copyWith(isSubmitting: false));
    }
  }

  /// Returns true on success, false on failure or user cancellation.
  Future<bool> registerWithGoogle() async {
    if (_state.isBusy) return false;
    _set(_state.copyWith(isGoogleLoading: true, errorMessage: null));
    try {
      final session = await _loginWithGoogle();
      return session != null;
    } on ApiException catch (e) {
      _set(_state.copyWith(errorMessage: _humanize(e)));
      return false;
    } catch (_) {
      _set(_state.copyWith(errorMessage: 'No se pudo registrar con Google.'));
      return false;
    } finally {
      _set(_state.copyWith(isGoogleLoading: false));
    }
  }

  // ---------- helpers ----------

  void _set(RegisterState next) {
    _state = next;
    notifyListeners();
  }

  String _humanize(ApiException e) {
    switch (e.code) {
      case 'CONFLICT':
        return 'Este correo ya está registrado. Inicia sesión.';
      case 'VALIDATION_ERROR':
        return e.message;
      case 'AUTH_ERROR':
        return 'No se pudo autenticar. Intenta de nuevo.';
      default:
        return e.message;
    }
  }
}
