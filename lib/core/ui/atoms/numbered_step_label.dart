import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Numbered uppercase label used by multi-step forms: "01 · NOMBRE DEL PROYECTO".
/// The number is rendered in a slightly muted shade so the label dominates.
class NumberedStepLabel extends StatelessWidget {
  final int step;
  final String label;
  const NumberedStepLabel({super.key, required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    final number = step.toString().padLeft(2, '0');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: number,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(
            text: '  ·  ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        height: 1.2,
      ),
    );
  }
}
