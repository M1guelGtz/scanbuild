import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/field_label.dart';

/// Combines a FieldLabel atom with a TextFormField. A molecule in the
/// Atomic Design sense — two atoms working together as a single unit.
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final FormFieldValidator<String>? validator;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.autocorrect = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          autocorrect: autocorrect,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.iconMuted, size: 20),
            suffixIcon: suffix,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
