import 'dart:io';
import 'package:flutter/services.dart';

class SecureScreen {
  static const _channel = MethodChannel('visionprice/secure_screen');

  static const bool kEnabled = true;

  static Future<void> enable() async {
    if (!kEnabled) return;
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('enable');
    } on PlatformException {
    }
  }

  static Future<void> disable() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('disable');
    } on PlatformException {
    }
  }
}
