import 'package:flutter/foundation.dart';

import '../../../../core/platform/mock_location_guard.dart';
import 'integrity_state.dart';

class IntegrityViewModel extends ChangeNotifier {
  IntegrityState _state = const IntegrityState();
  IntegrityState get state => _state;

  Future<IntegrityResult> evaluate() async {
    _state = _state.copyWith(isChecking: true);
    notifyListeners();
    final result = await MockLocationGuard.check();
    _state = IntegrityState(isChecking: false, result: result);
    notifyListeners();
    return result;
  }
}
