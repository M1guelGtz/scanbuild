import 'dart:io';
import 'package:flutter/services.dart';

class SecureScreen {
  static const _channel = MethodChannel('visionprice/secure_screen');

  /// Interruptor maestro de la protección anti-captura.
  ///
  /// - `true`  → comportamiento de seguridad activo (FLAG_SECURE on en login).
  /// - `false` → se permite capturar pantalla en TODAS las vistas.
  ///
  /// Para tomar evidencias del reporte:
  ///   1. Cambiar a `false`.
  ///   2. `flutter run` o reinstalar la app.
  ///   3. Tomar las capturas necesarias.
  ///   4. Restaurar a `true` antes de la entrega / build de release.
  static const bool kEnabled = true;

  static Future<void> enable() async {
    if (!kEnabled) return;
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('enable');
    } on PlatformException {
      // canal no disponible en este build — silencioso
    }
  }

  static Future<void> disable() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('disable');
    } on PlatformException {
      // canal no disponible en este build — silencioso
    }
  }
}
