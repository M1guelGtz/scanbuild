
class InactivityConfig {
  InactivityConfig._();

  static const int _minutes = int.fromEnvironment(
    'INACTIVITY_TIMEOUT_MINUTES',
    defaultValue: 5,
  );

  static const int _seconds = int.fromEnvironment(
    'INACTIVITY_TIMEOUT_SECONDS',
    defaultValue: 0,
  );


  static Duration get timeout {
    final raw = _seconds > 0 ? Duration(seconds: _seconds) : Duration(minutes: _minutes);
    return raw < const Duration(seconds: 5) ? const Duration(seconds: 5) : raw;
  }
}
