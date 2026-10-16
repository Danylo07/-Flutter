import 'package:flutter/foundation.dart';

/// Стан входу. Роутер слухає його через `refreshListenable`.
class AuthModel extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    if (_isLoggedIn) return;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    notifyListeners();
  }
}
