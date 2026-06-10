import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'wipe_service.dart';

/// Handler de SEGUNDO PLANO de FCM.
///
/// Debe ser una función TOP-LEVEL (o estática) anotada con
/// `@pragma('vm:entry-point')` porque Flutter la ejecuta en un isolate aparte,
/// sin el contexto de la app. Por eso re-inicializa Firebase antes de procesar.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Imprescindible en el isolate de background: Firebase no está inicializado.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('[FCM][background] Mensaje recibido: ${message.data}');
    await WipeService().handleMessage(message);
  } catch (e, st) {
    debugPrint('[FCM][background] Error: $e\n$st');
  }
}

/// Encapsula la configuración de Firebase Cloud Messaging en primer plano:
/// permisos, obtención del token y registro del handler `onMessage`.
class FcmService {
  final FirebaseMessaging _messaging;
  final WipeService _wipeService;

  FcmService({
    FirebaseMessaging? messaging,
    WipeService? wipeService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _wipeService = wipeService ?? WipeService();

  /// Inicializa permisos, token y listeners de primer plano.
  Future<void> init() async {
    try {
      // 1. Solicita permiso de notificaciones (iOS y Android 13+).
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        '[FCM] Permiso de notificaciones: ${settings.authorizationStatus}',
      );

      // 2. Obtiene e imprime el token (necesario para enviar mensajes de prueba).
      final token = await _messaging.getToken();
      debugPrint('═════════ FCM TOKEN ═════════');
      debugPrint('$token');
      debugPrint('═════════════════════════════');

      // Reimprime el token si Firebase lo rota.
      _messaging.onTokenRefresh.listen((t) {
        debugPrint('[FCM] Token actualizado: $t');
      });

      // 3. Handler de PRIMER PLANO: la app está abierta y visible.
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[FCM][foreground] Mensaje recibido: ${message.data}');
        _wipeService.handleMessage(message);
      });

      // 4. Cuando el usuario toca la notificación y abre la app desde background.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[FCM][opened] Mensaje abierto: ${message.data}');
        _wipeService.handleMessage(message);
      });
    } catch (e, st) {
      debugPrint('[FCM] Error en init: $e\n$st');
    }
  }
}
