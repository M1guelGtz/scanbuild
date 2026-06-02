import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/link_text.dart';

/// Plain prose + clickable LinkText in the same row, centered.
/// Example: "¿No tienes cuenta? Crear cuenta".
class InlineLinkText extends StatelessWidget {
  final String leading;
  final String linkText;
  final VoidCallback? onTap;

  const InlineLinkText({
    super.key,
    required this.leading,
    required this.linkText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          leading,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        LinkText(linkText, onTap: onTap),
      ],
    );
  }
}
