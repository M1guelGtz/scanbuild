import 'package:flutter/foundation.dart';

import '../../domain/use_cases/logout.dart';

class HomeViewModel extends ChangeNotifier {
  final Logout _logout;
  HomeViewModel(this._logout);

  bool _signingOut = false;
  bool get isSigningOut => _signingOut;

  Future<void> signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    notifyListeners();
    try {
      await _logout();
    } finally {
      _signingOut = false;
      notifyListeners();
    }
  }
}
