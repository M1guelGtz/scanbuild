import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'labeled_text_field.dart';

/// A LabeledTextField specialized for passwords: lock icon prefix and a
/// reveal/hide toggle as suffix. Internal state for visibility only.
class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final FormFieldValidator<String>? validator;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return LabeledTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      autocorrect: false,
      hintText: '••••••••',
      prefixIcon: Icons.lock_outline,
      validator: widget.validator,
      suffix: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextButton(
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.textSecondary,
          ),
          child: Text(
            _obscure ? 'MOSTRAR' : 'OCULTAR',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
