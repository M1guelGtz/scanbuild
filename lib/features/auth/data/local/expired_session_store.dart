import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExpiredSessionSnapshot {
  final String? accessToken;

  final String? refreshToken;

  final DateTime expiredAt;

  final Duration idleTimeout;

  const ExpiredSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.expiredAt,
    required this.idleTimeout,
  });
}

class ExpiredSessionStore {
  static const _accessKey = 'vp.inactivity.accessToken';
  static const _refreshKey = 'vp.inactivity.refreshToken';
  static const _expiredAtKey = 'vp.inactivity.expiredAt';
  static const _timeoutKey = 'vp.inactivity.timeoutSeconds';

  final FlutterSecureStorage _storage;

  ExpiredSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(ExpiredSessionSnapshot snapshot) async {
    await _writeOrDelete(_accessKey, snapshot.accessToken);
    await _writeOrDelete(_refreshKey, snapshot.refreshToken);
    await _storage.write(
      key: _expiredAtKey,
      value: snapshot.expiredAt.toIso8601String(),
    );
    await _storage.write(
      key: _timeoutKey,
      value: snapshot.idleTimeout.inSeconds.toString(),
    );
  }

  Future<ExpiredSessionSnapshot?> read() async {
    final expiredAtRaw = await _storage.read(key: _expiredAtKey);
    if (expiredAtRaw == null) return null;
    final expiredAt = DateTime.tryParse(expiredAtRaw);
    if (expiredAt == null) return null;
    final timeoutRaw = await _storage.read(key: _timeoutKey);
    return ExpiredSessionSnapshot(
      accessToken: await _storage.read(key: _accessKey),
      refreshToken: await _storage.read(key: _refreshKey),
      expiredAt: expiredAt,
      idleTimeout: Duration(seconds: int.tryParse(timeoutRaw ?? '') ?? 0),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _expiredAtKey);
    await _storage.delete(key: _timeoutKey);
  }

  Future<void> _writeOrDelete(String key, String? value) {
    if (value == null) return _storage.delete(key: key);
    return _storage.write(key: key, value: value);
  }
}
