import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/saved_credentials.dart';
import '../../domain/services/credentials_vault.dart';
import '../../domain/value_objects/auth_method.dart';

/// Persists SavedCredentials using flutter_secure_storage, which in turn
/// uses Keystore (Android EncryptedSharedPreferences) and Keychain (iOS)
/// underneath. Single JSON blob under one key — simpler than three keys
/// and atomic (no partial writes when overwriting).
class CredentialsVaultImpl implements CredentialsVault {
  static const _key = 'vp.biometric.credentials';

  final FlutterSecureStorage _storage;
  CredentialsVaultImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> save(SavedCredentials credentials) async {
    final payload = <String, dynamic>{
      'method': credentials.method.wire,
      'email': credentials.email,
      if (credentials.password != null) 'password': credentials.password,
    };
    await _storage.write(key: _key, value: jsonEncode(payload));
  }

  @override
  Future<SavedCredentials?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final method = AuthMethodX.fromWire(json['method'] as String);
      final email = json['email'] as String;
      switch (method) {
        case AuthMethod.password:
          return SavedCredentials.password(
            email: email,
            password: json['password'] as String,
          );
        case AuthMethod.google:
          return SavedCredentials.google(email: email);
      }
    } catch (_) {
      // Corrupt blob — clear and pretend it never existed.
      await _storage.delete(key: _key);
      return null;
    }
  }

  @override
  Future<bool> hasAny() async {
    final raw = await _storage.read(key: _key);
    return raw != null && raw.isNotEmpty;
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
