import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centraliza el acceso a [FlutterSecureStorage] para los datos sensibles de
/// ScanBuild y para la palabra clave del borrado remoto.
///
/// Mantener todas las claves aquí evita "claves mágicas" repartidas por la app
/// y permite que el [WipeService] borre todo de forma consistente.
class SecureStorageService {
  // --- Claves de los datos sensibles que se borran en el wipe ---
  static const String kJwtAccessToken = 'jwt_access_token';
  static const String kJwtRefreshToken = 'jwt_refresh_token';
  static const String kSqlcipherKey = 'sqlcipher_key';
  static const String kClienteDatos = 'cliente_datos';

  /// Palabra clave del usuario que autoriza el borrado. NO se considera un
  /// "dato sensible de negocio": no se elimina en [deleteSensitiveData] para
  /// que el dispositivo siga reconociendo futuros comandos de wipe.
  static const String kWipeKeyword = 'wipe_keyword';

  /// Lista de los 4 datos sensibles que el wipe debe eliminar.
  static const List<String> sensitiveKeys = <String>[
    kJwtAccessToken,
    kJwtRefreshToken,
    kSqlcipherKey,
    kClienteDatos,
  ];

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // En Android usa EncryptedSharedPreferences (cifrado respaldado
              // por el Keystore del sistema) en lugar del SharedPreferences plano.
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Escribe (o sobreescribe) un valor asociado a [key].
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lee el valor de [key]; devuelve `null` si no existe.
  Future<String?> read(String key) => _storage.read(key: key);

  /// Borra TODOS los datos sensibles de negocio (los 4 de [sensitiveKeys]).
  ///
  /// Es idempotente: borrar una clave inexistente no lanza excepción, por lo
  /// que puede ejecutarse varias veces sin problema.
  Future<void> deleteAll() async {
    for (final key in sensitiveKeys) {
      await _storage.delete(key: key);
    }
  }

  /// Indica si queda al menos uno de los datos sensibles almacenados.
  /// Útil para mostrar en la UI si "hay datos que borrar".
  Future<bool> hasSensitiveData() async {
    for (final key in sensitiveKeys) {
      if (await _storage.read(key: key) != null) return true;
    }
    return false;
  }

  /// Rellena los 4 datos sensibles con valores de ejemplo para poder demostrar
  /// el borrado. NO toca la palabra clave del usuario.
  Future<void> seedDemoData() async {
    await write(kJwtAccessToken, 'demo.access.jwt.eyJhbGciOiJIUzI1NiJ9');
    await write(kJwtRefreshToken, 'demo.refresh.jwt.eyJhbGciOiJIUzI1NiJ9');
    await write(kSqlcipherKey, 'demo-sqlcipher-passphrase-0123456789');
    await write(
      kClienteDatos,
      jsonEncode(<String, dynamic>{
        'nombre': 'Cliente Demo S.L.',
        'contacto': 'demo@cliente.example',
        'telefono': '+34 600 000 000',
        'presupuesto': 'PRESU-2026-0042',
      }),
    );
  }
}
