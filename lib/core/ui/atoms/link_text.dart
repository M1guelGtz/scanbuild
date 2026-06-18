import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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
