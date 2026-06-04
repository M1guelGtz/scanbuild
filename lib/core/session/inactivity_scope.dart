import 'package:flutter/widgets.dart';

import 'inactivity_monitor.dart';


class InactivityScope extends StatefulWidget {
  final Duration timeout;

  final Future<void> Function() onTimeout;

  final Widget child;

  const InactivityScope({
    super.key,
    required this.timeout,
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityScope> createState() => _InactivityScopeState();
}

class _InactivityScopeState extends State<InactivityScope> {
  late final InactivityMonitor _monitor;

  @override
  void initState() {
    super.initState();
    _monitor = InactivityMonitor(
      timeout: widget.timeout,
      onTimeout: widget.onTimeout,
    )..start();
  }

  @override
  void dispose() {
    _monitor.dispose();
    super.dispose();
  }

  void _poke([_]) => _monitor.registerActivity();

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _poke,
      onPointerMove: _poke,
      onPointerSignal: _poke,
      child: widget.child,
    );
  }
}
