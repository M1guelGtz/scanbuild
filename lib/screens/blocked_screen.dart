import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_location_guard.dart';
import '../theme/app_theme.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        ModalRoute.of(context)?.settings.arguments as IntegrityResult?;
    final status = result?.status ?? IntegrityStatus.unknownError;
    final detail = result?.detail ?? 'No se pudo verificar la integridad del dispositivo.';

    final isMock = status == IntegrityStatus.mockDetected;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isMock ? Colors.red : Colors.orange)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isMock ? Icons.gpp_bad_outlined : Icons.warning_amber_rounded,
                  size: 44,
                  color: isMock ? Colors.red : Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                isMock
                    ? 'Acceso bloqueado'
                    : 'No se pudo verificar el dispositivo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isMock) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '¿Cómo desbloquear?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      _Step(
                        text:
                            'Desactiva o desinstala cualquier aplicación de Fake GPS.',
                      ),
                      _Step(
                        text:
                            'En Opciones de Desarrollador → "Seleccionar app de ubicación simulada" elige "Ninguna".',
                      ),
                      _Step(
                        text: 'Reinicia la aplicación.',
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Cerrar aplicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String text;
  const _Step({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
