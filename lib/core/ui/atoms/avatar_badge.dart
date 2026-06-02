import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Circular avatar with initials + optional blue notification dot.
///
/// Implementation note: a previous version wrapped a Material in
/// `Positioned.fill` inside a Stack. That combo triggered a Flutter
/// assertion in `flushSemantics` (`!semantics.parentDataDirty`) on Android.
/// The current layout (Stack with one default child + one Positioned dot)
/// avoids it and renders identically.
class AvatarBadge extends StatelessWidget {
  final String initials;
  final bool hasNotification;
  final VoidCallback? onTap;
  final double size;

  const AvatarBadge({
    super.key,
    required this.initials,
    this.hasNotification = false,
    this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final letters = initials.length > 2
        ? initials.substring(0, 2).toUpperCase()
        : initials.toUpperCase();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              letters,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (hasNotification)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
