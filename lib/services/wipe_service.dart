import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'secure_storage_service.dart';

class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const AndroidNotificationChannel _securityChannel =
      AndroidNotificationChannel(
    'security_channel',
    'Seguridad ScanBuild',
    description: 'Avisos de seguridad como el borrado remoto de datos.',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_securityChannel);

    _initialized = true;
  }

  static Future<void> showWipeConfirmation() async {
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
      1001,
      'ScanBuild — Seguridad',
      'Tus datos sensibles fueron eliminados de forma segura.',
      details,
    );
  }
}

class WipeService {
  final SecureStorageService _storage;

  WipeService({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService();

  Future<void> handleMessage(RemoteMessage message) async {
    try {
      final data = message.data;

      if (data['accion'] != 'wipe') return;

      final stored = await _storage.read(SecureStorageService.kWipeKeyword);
      if (stored == null || stored.trim().isEmpty) {
        debugPrint('[WipeService] No hay palabra clave configurada; ignorado.');
        return;
      }

      final received = (data['clave'] ?? '').toString();
      final matches =
          stored.trim().toLowerCase() == received.trim().toLowerCase();

      if (!matches) {
        debugPrint('[WipeService] Palabra clave no coincide; ignorado.');
        return;
      }

      await _storage.deleteAll();
      debugPrint('[WipeService] Borrado remoto ejecutado correctamente.');

      await LocalNotifications.showWipeConfirmation();
    } catch (e, st) {
      debugPrint('[WipeService] Error procesando el mensaje de wipe: $e\n$st');
    }
  }
}
