import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/platform/secure_screen.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/atoms/divider_with_label.dart';
import '../../../../core/ui/atoms/google_icon.dart';
import '../../../../core/ui/atoms/primary_button.dart';
import '../../../../core/ui/molecules/inline_link_text.dart';
import '../../../../core/ui/molecules/labeled_text_field.dart';
import '../../../../core/ui/molecules/password_field.dart';
import '../../../../core/ui/organisms/brand_header.dart';
import '../../di/auth_module.dart';
import '../view_models/register_state.dart';
import '../view_models/register_view_model.dart';

/// Email/password registration + Google sign-up. Both routes converge on
/// the same /projects landing page on success.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final module = context.read<AuthModule>();
    return ChangeNotifierProvider<RegisterViewModel>(
      create: (_) => module.registerViewModelFactory(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The /login screen turns FLAG_SECURE on; reaffirm it for /register too
    // so screenshots of the create-account form are also blocked.
    SecureScreen.enable();
  }

  @override
  void dispose() {
    SecureScreen.disable();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(RegisterViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await vm.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      SecureScreen.disable();
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.projects,
        (_) => false,
      );
    }
  }

  Future<void> _onGoogle(RegisterViewModel vm) async {
    final ok = await vm.registerWithGoogle();
    if (!mounted) return;
    if (ok) {
      SecureScreen.disable();
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.projects,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<RegisterViewModel>(
          builder: (context, vm, _) {
            // Surface errors via SnackBar (no overlapping widgets that could
            // break the render tree).
            if (vm.state.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final msg = vm.state.errorMessage;
                if (msg == null || !mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                vm.clearError();
              });
            }
            final state = vm.state;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topBar(),
                    const SizedBox(height: 20),
                    const BrandHeader(),
                    const SizedBox(height: 24),
                    Text(
                      'Crear cuenta',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Empieza a presupuestar tus proyectos en minutos.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    LabeledTextField(
                      label: 'NOMBRE',
                      controller: _name,
                      enabled: !state.isBusy,
                      hintText: 'Tu nombre completo',
                      prefixIcon: Icons.person_outline,
                      autocorrect: false,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        if (v.trim().length < 2) return 'Nombre muy corto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    LabeledTextField(
                      label: 'CORREO',
                      controller: _email,
                      enabled: !state.isBusy,
                      hintText: 'tu@correo.com',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu correo';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    PasswordField(
                      label: 'CONTRASEÑA',
                      controller: _password,
                      enabled: !state.isBusy,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (v.length < 8) return 'Mínimo 8 caracteres';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) {
                          return 'Debe incluir al menos 1 mayúscula';
                        }
                        if (!RegExp(r'\d').hasMatch(v)) {
                          return 'Debe incluir al menos 1 número';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '8+ caracteres, una mayúscula y un número.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _termsRow(state, vm),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Crear cuenta',
                      trailingIcon: Icons.arrow_forward,
                      loading: state.isSubmitting,
                      onPressed: state.isBusy ? null : () => _onSubmit(vm),
                    ),
                    const SizedBox(height: 22),
                    const DividerWithLabel('O REGÍSTRATE CON'),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed:
                          state.isBusy ? null : () => _onGoogle(vm),
                      icon: state.isGoogleLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const GoogleIcon(),
                      label: const Text('Continuar con Google'),
                    ),
                    const SizedBox(height: 22),
                    InlineLinkText(
                      leading: '¿Ya tienes cuenta? ',
                      linkText: 'Inicia sesión',
                      onTap: state.isBusy
                          ? null
                          : () => Navigator.of(context)
                              .pushReplacementNamed(Routes.login),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _termsRow(RegisterState state, RegisterViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: Checkbox(
            value: state.acceptedTerms,
            onChanged: state.isBusy
                ? null
                : (v) => vm.setAcceptedTerms(v ?? false),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Acepto los términos de servicio y la política de privacidad.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
