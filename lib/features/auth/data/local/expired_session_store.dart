import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Snapshot of the session that was closed because the user went idle.
class ExpiredSessionSnapshot {
  /// Access token that was live at the moment of the idle logout.
  final String? accessToken;

  /// Refresh token that was live at the moment of the idle logout.
  final String? refreshToken;

  /// Wall-clock instant at which the session was declared idle.
  final DateTime expiredAt;

  /// The idle window that was in effect (the "variable de tiempo").
  final Duration idleTimeout;

  const ExpiredSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.expiredAt,
    required this.idleTimeout,
  });
}

/// Persists, in the platform's encrypted keystore, the tokens and the timing
/// variable of the last session that was closed due to inactivity.
///
/// This is deliberately separate from [TokenStorage]: the live token pair is
/// wiped on logout, but the requirement is to keep an *encrypted* record of
/// what was active when the idle logout fired (token + time variable), e.g.
/// for auditing or a future "resume where you left off" feature.
class ExpiredSessionStore {
  static const _accessKey = 'vp.inactivity.accessToken';
  static const _refreshKey = 'vp.inactivity.refreshToken';
  static const _expiredAtKey = 'vp.inactivity.expiredAt';
  static const _timeoutKey = 'vp.inactivity.timeoutSeconds';

  final FlutterSecureStorage _storage;

  ExpiredSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Stores the snapshot. Null tokens are written as deletions so a stale
  /// value from a previous expiry never lingers.
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

  /// Reads back the last idle-logout snapshot, or null if none was recorded.
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
