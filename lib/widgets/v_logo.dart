import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VLogo extends StatelessWidget {
  final double size;
  const VLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: CustomPaint(
        painter: _VPainter(),
      ),
    );
  }
}

class _VPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.13;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.5, h * 0.7)
      ..lineTo(w * 0.72, h * 0.36);
    canvas.drawPath(path, paint);

    final dot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.7), stroke * 0.55, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
