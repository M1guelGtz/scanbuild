import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/google_icon.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback? onFaceIdPressed;
  final VoidCallback? onGooglePressed;
  final bool googleLoading;
  final bool faceIdLoading;
  final bool faceIdEnabled;
  final bool enabled;

  const SocialAuthButtons({
    super.key,
    this.onFaceIdPressed,
    this.onGooglePressed,
    this.googleLoading = false,
    this.faceIdLoading = false,
    this.faceIdEnabled = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final faceIdAvailable = enabled && faceIdEnabled && !faceIdLoading;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: faceIdAvailable ? onFaceIdPressed : null,
            icon: faceIdLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.fingerprint,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
            label: const Text('Face ID'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled && !googleLoading ? onGooglePressed : null,
            icon: googleLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const GoogleIcon(),
            label: const Text('Google'),
          ),
        ),
      ],
    );
  }
}
