import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class VLogo extends StatelessWidget {
  final double size;
  const VLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Text(
        'V',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.6,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
