import 'dart:io';
import 'package:flutter/services.dart';

class SecureScreen {
  static const _channel = MethodChannel('visionprice/secure_screen');

  static Future<void> enable() async {
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
