import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/v_logo.dart';

class BrandHeader extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  const BrandHeader({super.key, this.logoSize = 32, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VLogo(size: logoSize),
        const SizedBox(width: 10),
        Text(
          'VisionPrice',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
