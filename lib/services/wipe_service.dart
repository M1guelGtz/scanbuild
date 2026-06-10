import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'secure_storage_service.dart';

/// Helper estático para las notificaciones locales de seguridad.
///
/// Se mantiene estático para que pueda usarse tanto desde el isolate principal
/// (primer plano) como desde el isolate del background handler de FCM, donde no
/// hay acceso a los singletons creados por la UI.
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Canal Android dedicado para los avisos de seguridad.
  static const AndroidNotificationChannel _securityChannel =
      AndroidNotificationChannel(
    'security_channel',
    'Seguridad ScanBuild',
    description: 'Avisos de seguridad como el borrado remoto de datos.',
    importance: Importance.high,
  );

  /// Inicializa el plugin y crea el canal. Idempotente.
  static Future<void> init() async {
    if (_initialized) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Registra el canal explícitamente (necesario en Android 8+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_securityChannel);

    _initialized = true;
  }

  /// Muestra la notificación local que confirma el borrado seguro.
  static Future<void> showWipeConfirmation() async {
    // En el isolate de background puede no haberse llamado a init() todavía.
    await init();

    final androidDetails = AndroidNotificationDetails(
      _securityChannel.id,
      _securityChannel.name,
      channelDescription: _securityChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      // ID fijo: una sola confirmación de wipe a la vez.
      1001,
      'ScanBuild — Seguridad',
      'Tus datos sensibles fueron eliminados de forma segura.',
      details,
    );
  }
}

/// Orquesta el borrado remoto de emergencia disparado por un Data Message FCM.
class WipeService {
  final SecureStorageService _storage;

  WipeService({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService();

  /// Procesa un [RemoteMessage]. Si es un comando de wipe válido (acción +
  /// palabra clave correcta), borra los datos sensibles y notifica al usuario.
  ///
  /// Es defensivo e idempotente: cualquier fallo se captura y se registra sin
  /// propagar excepciones, y borrar sin datos no produce error.
  Future<void> handleMessage(RemoteMessage message) async {
    try {
      final data = message.data;

      // 1. Solo nos interesan los mensajes con acción de borrado.
      if (data['accion'] != 'wipe') return;

      // 2. La palabra clave SIEMPRE se lee del secure storage (nunca hardcode).
      final stored = await _storage.read(SecureStorageService.kWipeKeyword);
      if (stored == null || stored.trim().isEmpty) {
        debugPrint('[WipeService] No hay palabra clave configurada; ignorado.');
        return;
      }

      // 3. Comparación segura: trim + case-insensitive.
      final received = (data['clave'] ?? '').toString();
      final matches =
          stored.trim().toLowerCase() == received.trim().toLowerCase();

      if (!matches) {
        // Clave incorrecta: se ignora silenciosamente (sin pistas al atacante).
        debugPrint('[WipeService] Palabra clave no coincide; ignorado.');
        return;
      }

      // 4. Coincide: ejecuta el borrado de los 4 datos sensibles.
      await _storage.deleteAll();
      debugPrint('[WipeService] Borrado remoto ejecutado correctamente.');

      // 5. Confirma localmente al usuario.
      await LocalNotifications.showWipeConfirmation();
    } catch (e, st) {
      // Nunca dejamos que un fallo en el handler tumbe la app / el isolate.
      debugPrint('[WipeService] Error procesando el mensaje de wipe: $e\n$st');
    }
  }
}
