import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsbDebugBlockApp extends StatelessWidget {
  const UsbDebugBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _UsbDebugBlockScreen(),
    );
  }
}

class UsbDebugBlockDialog extends StatelessWidget {
  final VoidCallback onClose;

  const UsbDebugBlockDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: const Icon(Icons.gpp_bad_outlined, color: Colors.red, size: 40),
        title: const Text('Acceso bloqueado por seguridad'),
        content: const Text(
          'Se ha detectado que la Depuración USB (ADB) está activada en este '
          'dispositivo.\n\n'
          'Por políticas de seguridad, la aplicación no puede ejecutarse en un '
          'entorno potencialmente inseguro.\n\n'
          'Desactiva la Depuración USB en Ajustes → Opciones de desarrollador '
          'y vuelve a abrir la aplicación.',
        ),
        actions: [
          FilledButton(
            onPressed: onClose,
            child: const Text('Cerrar aplicación'),
          ),
        ],
      ),
    );
  }
}

class _UsbDebugBlockScreen extends StatefulWidget {
  const _UsbDebugBlockScreen();

  @override
  State<_UsbDebugBlockScreen> createState() => _UsbDebugBlockScreenState();
}

class _UsbDebugBlockScreenState extends State<_UsbDebugBlockScreen> {
  static const Duration _autoCloseDelay = Duration(seconds: 8);

  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBlockingDialog());
    _autoCloseTimer = Timer(_autoCloseDelay, _closeApp);
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _closeApp() {
    _autoCloseTimer?.cancel();
    SystemNavigator.pop();
  }

  Future<void> _showBlockingDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UsbDebugBlockDialog(onClose: _closeApp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.security, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Entorno no seguro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Depuración USB activa. La aplicación se cerrará por seguridad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
