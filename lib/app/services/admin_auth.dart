import 'dart:convert';

import 'package:crypto/crypto.dart';

class AdminAuth {
  // SHA-256 da senha admin, passado no build:
  // --dart-define=ADMIN_PASSWORD_HASH=<hash>
  static const String _passwordHash =
      String.fromEnvironment("ADMIN_PASSWORD_HASH");

  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  bool login(String password) {
    if (_passwordHash.isEmpty) return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    _isAdmin = hash == _passwordHash.toLowerCase();
    return _isAdmin;
  }

  void logout() {
    _isAdmin = false;
  }
}
