import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/link_text.dart';

/// "Mantener sesión" checkbox on the left + a forgot-password LinkText on
/// the right. Stateless — both interactions are reported via callbacks.
class RememberMeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onForgotTap;
  final String rememberLabel;
  final String forgotLabel;

  const RememberMeRow({
    super.key,
    required this.value,
    this.onChanged,
    this.onForgotTap,
    this.rememberLabel = 'Mantener sesión',
    this.forgotLabel = '¿Olvidaste?',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          rememberLabel,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const Spacer(),
        LinkText(forgotLabel, onTap: onForgotTap),
      ],
    );
  }
}
