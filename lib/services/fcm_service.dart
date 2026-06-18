import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'wipe_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('[FCM][background] Mensaje recibido: ${message.data}');
    await WipeService().handleMessage(message);
  } catch (e, st) {
    debugPrint('[FCM][background] Error: $e\n$st');
  }
}

class FcmService {
  final FirebaseMessaging _messaging;
  final WipeService _wipeService;

  FcmService({
    FirebaseMessaging? messaging,
    WipeService? wipeService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _wipeService = wipeService ?? WipeService();

  Future<void> init() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        '[FCM] Permiso de notificaciones: ${settings.authorizationStatus}',
      );

      final token = await _messaging.getToken();
      debugPrint('═════════ FCM TOKEN ═════════');
      debugPrint('$token');
      debugPrint('═════════════════════════════');

      _messaging.onTokenRefresh.listen((t) {
        debugPrint('[FCM] Token actualizado: $t');
      });

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[FCM][foreground] Mensaje recibido: ${message.data}');
        _wipeService.handleMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[FCM][opened] Mensaje abierto: ${message.data}');
        _wipeService.handleMessage(message);
      });
    } catch (e, st) {
      debugPrint('[FCM] Error en init: $e\n$st');
    }
  }
}
