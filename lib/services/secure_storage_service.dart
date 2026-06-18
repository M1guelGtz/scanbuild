import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String kJwtAccessToken = 'jwt_access_token';
  static const String kJwtRefreshToken = 'jwt_refresh_token';
  static const String kSqlcipherKey = 'sqlcipher_key';
  static const String kClienteDatos = 'cliente_datos';

  static const String kWipeKeyword = 'wipe_keyword';

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
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> deleteAll() async {
    for (final key in sensitiveKeys) {
      await _storage.delete(key: key);
    }
  }

  Future<bool> hasSensitiveData() async {
    for (final key in sensitiveKeys) {
      if (await _storage.read(key: key) != null) return true;
    }
    return false;
  }

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
