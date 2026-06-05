import 'dart:io';
import 'package:geolocator/geolocator.dart';

enum IntegrityStatus {
  ok,
  mockDetected,
  locationServiceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unsupportedPlatform,
  unknownError,
}

class IntegrityResult {
  final IntegrityStatus status;
  final String? detail;
  const IntegrityResult(this.status, [this.detail]);

  bool get isBlocking =>
      status == IntegrityStatus.mockDetected ||
      status == IntegrityStatus.locationServiceDisabled ||
      status == IntegrityStatus.permissionDenied ||
      status == IntegrityStatus.permissionDeniedForever;
}
class MockLocationGuard {
  static Future<IntegrityResult> check() async {
    if (!Platform.isAndroid) {
      return const IntegrityResult(IntegrityStatus.ok,
          'Plataforma sin detección de mock locations.');
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const IntegrityResult(
          IntegrityStatus.locationServiceDisabled,
          'El servicio de ubicación está apagado. Actívalo para continuar.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const IntegrityResult(
          IntegrityStatus.permissionDenied,
          'La app necesita permiso de ubicación para verificar la integridad del dispositivo.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return const IntegrityResult(
          IntegrityStatus.permissionDeniedForever,
          'El permiso de ubicación está bloqueado permanentemente. Habilítalo manualmente en los ajustes del sistema.',
        );
      }
     Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (position.isMocked) {
        return const IntegrityResult(
          IntegrityStatus.mockDetected,
          'Se detectó una ubicación falsa (Fake GPS / mock location). '
              'Por seguridad, esta aplicación no puede ejecutarse en este dispositivo.',
        );
      }

      return const IntegrityResult(IntegrityStatus.ok);
    } catch (e) {
      return IntegrityResult(IntegrityStatus.unknownError, e.toString());
    }
  }
}
