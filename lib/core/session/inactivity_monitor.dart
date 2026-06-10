import 'dart:async';

import 'package:flutter/widgets.dart';


class InactivityMonitor with WidgetsBindingObserver {
  final Duration timeout;
  final Future<void> Function() onTimeout;

  Timer? _timer;
  DateTime? _lastActivity;
  bool _firing = false;
  bool _started = false;

  InactivityMonitor({required this.timeout, required this.onTimeout});

 
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    registerActivity();
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }


  void registerActivity() {
    if (!_started || _firing) return;
    _lastActivity = DateTime.now();
    _arm(timeout);
  }

  void _arm(Duration d) {
    _timer?.cancel();
    _timer = Timer(d, _onTimerElapsed);
  }

  Future<void> _onTimerElapsed() async {
    final last = _lastActivity;
    if (last == null) return;
    final idle = DateTime.now().difference(last);
    if (idle < timeout) {
     
      _arm(timeout - idle);
      return;
    }
    await _fire();
  }

  Future<void> _fire() async {
    if (_firing) return;
    _firing = true;
    _timer?.cancel();
    _timer = null;
    try {
      await onTimeout();
    } finally {
      _firing = false;
    
      if (_started) registerActivity();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started) return;
    if (state == AppLifecycleState.resumed) {
      final last = _lastActivity;
      if (last != null && DateTime.now().difference(last) >= timeout) {
        unawaited(_fire());
      } else if (last != null) {
        _arm(timeout - DateTime.now().difference(last));
      } else {
        registerActivity();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {

      _timer?.cancel();
      _timer = null;
    }
  }
}
