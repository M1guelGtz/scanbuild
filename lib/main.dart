import 'package:flutter/material.dart';

import 'features/auth/data/datasources/remote/google_sign_in_service.dart';
import 'vision_price.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Surface widget-tree exceptions to the console with a full stack so we
  // never end up looking at a silent gray rectangle. Keep the default
  // ErrorWidget rather than overriding it — debug builds already show a
  // useful red banner.
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

  // DevicePreview is intentionally NOT used: even with `enabled: kIsWeb` it
  // wraps the whole app in extra widgets (overlay + clip + transformation
  // layers) that interact badly with Flutter 3.44's semantics pipeline,
  // producing cascades of `!semantics.parentDataDirty` and
  // `RenderBox was not laid out` exceptions on Android.
  runApp(const VisionPriceApp());
}
