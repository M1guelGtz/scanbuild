import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/integrity_gate_screen.dart';
import 'screens/blocked_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const VisionPriceApp());
}

class VisionPriceApp extends StatelessWidget {
  const VisionPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionPrice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (_) => const IntegrityGateScreen(),
        '/blocked': (_) => const BlockedScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeShell(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
