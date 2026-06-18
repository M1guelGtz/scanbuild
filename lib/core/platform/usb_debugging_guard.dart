import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UsbDebuggingGuard {
  const UsbDebuggingGuard._();

  static const MethodChannel _channel =
      MethodChannel('visionprice/usb_debugging');

  static const EventChannel _eventChannel =
      EventChannel('visionprice/usb_debugging_events');

  static Future<bool> isUsbDebuggingEnabled() async {
    if (kDebugMode) return false;

    if (!Platform.isAndroid) return false;

    try {
      final bool enabled =
          await _channel.invokeMethod<bool>('isUsbDebuggingEnabled') ?? false;
      return enabled;
    } on PlatformException catch (e) {
      debugPrint('[UsbDebuggingGuard] Error nativo: ${e.message}');
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  static Stream<bool> watch() {
    if (kDebugMode) return const Stream<bool>.empty();
    if (!Platform.isAndroid) return const Stream<bool>.empty();

    return _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event == true)
        .handleError((Object error) {
      debugPrint('[UsbDebuggingGuard] Error en el stream: $error');
    });
  }
}
