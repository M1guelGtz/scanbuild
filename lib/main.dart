import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'features/auth/data/datasources/remote/google_sign_in_service.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'services/wipe_service.dart';
import 'vision_price.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  FlutterError.onError = (details) {
    debugPrint('═════════ Flutter widget error ═════════');
    debugPrint('${details.exception}');
    debugPrint('${details.stack}');
    debugPrint('Library: ${details.library} · Widget: ${details.context}');
    debugPrint('════════════════════════════════════════');
    FlutterError.presentError(details);
  };

  // --- Firebase + borrado remoto de emergencia (FCM) ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Registra el handler de SEGUNDO PLANO (función top-level vm:entry-point).
    // Debe registrarse antes de runApp.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Prepara las notificaciones locales (canal de seguridad) y los listeners
    // de primer plano + el token de pruebas.
    await LocalNotifications.init();
    await FcmService().init();
  } catch (e) {
    debugPrint('Error inicializando Firebase/FCM: $e');
  }

  try {
    await GoogleSignInService.ensureInitialized();
  } catch (_) {/* non-fatal: will retry on first use */}


  runApp(const VisionPriceApp());
}
