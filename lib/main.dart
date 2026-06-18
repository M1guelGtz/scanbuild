import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/platform/usb_debugging_guard.dart';
import 'core/security/usb_debug_block_app.dart';
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

  if (await UsbDebuggingGuard.isUsbDebuggingEnabled()) {
    runApp(const UsbDebugBlockApp());
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await LocalNotifications.init();
    await FcmService().init();
  } catch (e) {
    debugPrint('Error inicializando Firebase/FCM: $e');
  }

  try {
    await GoogleSignInService.ensureInitialized();
  } catch (_) {}


  runApp(const VisionPriceApp());
}
