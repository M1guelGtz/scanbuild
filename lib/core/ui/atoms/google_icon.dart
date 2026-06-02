import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 18×18 dark circle with a white "G". Stand-in for the real Google logo
/// to avoid bundling the brand SVG; swap to the official asset when
/// publishing publicly.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
