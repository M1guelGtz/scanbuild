import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/platform/secure_screen.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/ui/atoms/divider_with_label.dart';
import '../../../../core/ui/atoms/primary_button.dart';
import '../../../../core/ui/molecules/inline_link_text.dart';
import '../../../../core/ui/molecules/labeled_text_field.dart';
import '../../../../core/ui/molecules/password_field.dart';
import '../../../../core/ui/molecules/remember_me_row.dart';
import '../../../../core/ui/organisms/social_auth_buttons.dart';
import '../../../../core/ui/templates/auth_template.dart';
import '../../di/auth_module.dart';
import '../view_models/login_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final module = context.read<AuthModule>();
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => module.loginViewModelFactory(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    SecureScreen.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LoginViewModel>().resolveBiometricAvailability();
    });
  }

  @override
  void dispose() {
    SecureScreen.disable();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await vm.loginWithPassword(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      await _maybeShowEnrollDialog(vm);
      if (!mounted) return;
      SecureScreen.disable();
      Navigator.of(context).pushReplacementNamed(Routes.projects);
    }
  }

  Future<void> _onGoogle(LoginViewModel vm) async {
    final ok = await vm.loginWithGoogle();
    if (!mounted) return;
    if (ok) {
      await _maybeShowEnrollDialog(vm);
      if (!mounted) return;
      SecureScreen.disable();
      Navigator.of(context).pushReplacementNamed(Routes.projects);
    }
  }

  Future<void> _onBiometric(LoginViewModel vm) async {
    final ok = await vm.loginWithBiometric();
    if (!mounted) return;
    if (ok) {
      SecureScreen.disable();
      Navigator.of(context).pushReplacementNamed(Routes.projects);
    }
  }

  Future<void> _maybeShowEnrollDialog(LoginViewModel vm) async {
    if (!vm.state.shouldOfferBiometricEnroll) return;
    final accept = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activar acceso rápido'),
        content: const Text(
          'Usa tu huella o Face ID para entrar la próxima vez sin escribir '
          'tu correo y contraseña. Puedes desactivarlo al cerrar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ahora no'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
    if (accept == true) {
      await vm.acceptBiometricEnroll();
    } else {
      vm.declineBiometricEnroll();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        if (vm.state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final message = vm.state.errorMessage;
            if (message == null || !mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
            vm.clearError();
          });
        }

        final state = vm.state;
        return AuthTemplate(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inicia sesión',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Accede a tus proyectos y presupuestos en cualquier dispositivo.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: 'CORREO',
                  controller: _emailCtrl,
                  enabled: !state.isBusy,
                  hintText: 'tu@correo.com',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                PasswordField(
                  label: 'CONTRASEÑA',
                  controller: _passwordCtrl,
                  enabled: !state.isBusy,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                RememberMeRow(
                  value: state.keepSession,
                  onChanged: state.isBusy ? null : vm.setKeepSession,
                  onForgotTap: state.isBusy
                      ? null
                      : () => Navigator.of(context).pushNamed(Routes.forgot),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Continuar',
                  trailingIcon: Icons.arrow_forward,
                  loading: state.isSubmitting,
                  onPressed: state.isBusy ? null : () => _onContinue(vm),
                ),
                const SizedBox(height: 22),
                const DividerWithLabel('O CONTINÚA CON'),
                const SizedBox(height: 16),
                SocialAuthButtons(
                  enabled: !state.isBusy,
                  googleLoading: state.isGoogleLoading,
                  faceIdLoading: state.isBiometricLoading,
                  faceIdEnabled: state.biometricAvailable,
                  onFaceIdPressed: () => _onBiometric(vm),
                  onGooglePressed: () => _onGoogle(vm),
                ),
                const SizedBox(height: 22),
                InlineLinkText(
                  leading: '¿No tienes cuenta? ',
                  linkText: 'Crear cuenta',
                  onTap: state.isBusy
                      ? null
                      : () => Navigator.of(context).pushNamed(Routes.register),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

