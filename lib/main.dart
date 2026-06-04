import 'package:flutter/material.dart';

import 'features/auth/data/datasources/remote/google_sign_in_service.dart';
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

  try {
    await GoogleSignInService.ensureInitialized();
  } catch (_) {/* non-fatal: will retry on first use */}

  
  runApp(const VisionPriceApp());
}
