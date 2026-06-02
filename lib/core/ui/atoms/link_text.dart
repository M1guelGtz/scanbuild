import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Inline text styled as a link (primary color, semibold). Tap target is
/// the text itself; for larger tap targets wrap in InkWell at the call site.
class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const LinkText(this.text, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
