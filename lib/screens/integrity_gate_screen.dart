import 'package:flutter/material.dart';
import '../services/mock_location_guard.dart';
import '../theme/app_theme.dart';
import '../widgets/v_logo.dart';

class IntegrityGateScreen extends StatefulWidget {
  const IntegrityGateScreen({super.key});

  @override
  State<IntegrityGateScreen> createState() => _IntegrityGateScreenState();
}

class _IntegrityGateScreenState extends State<IntegrityGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  Future<void> _evaluate() async {
    final result = await MockLocationGuard.check();
    if (!mounted) return;

    if (result.isBlocking) {
      Navigator.of(context).pushReplacementNamed(
        '/blocked',
        arguments: result,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              VLogo(size: 64),
              SizedBox(height: 18),
              Text(
                'VisionPrice',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Verificando integridad del dispositivo…',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
