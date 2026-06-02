import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/atoms/v_logo.dart';
import '../../di/auth_module.dart';
import '../view_models/integrity_view_model.dart';

class IntegrityGatePage extends StatelessWidget {
  const IntegrityGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final module = context.read<AuthModule>();
    return ChangeNotifierProvider<IntegrityViewModel>(
      create: (_) => module.integrityViewModelFactory(),
      child: const _IntegrityGateView(),
    );
  }
}

class _IntegrityGateView extends StatefulWidget {
  const _IntegrityGateView();

  @override
  State<_IntegrityGateView> createState() => _IntegrityGateViewState();
}

class _IntegrityGateViewState extends State<_IntegrityGateView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  Future<void> _evaluate() async {
    final vm = context.read<IntegrityViewModel>();
    final result = await vm.evaluate();
    if (!mounted) return;
    if (result.isBlocking) {
      Navigator.of(context).pushReplacementNamed(Routes.blocked, arguments: result);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
