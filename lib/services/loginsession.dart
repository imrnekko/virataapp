import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static final _storage = FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyPassword = 'password';

  static Future setEmail(String email) async =>
      await _storage.write(key: _keyEmail, value: email);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _keyEmail);

  static Future removeAll() async => await _storage.deleteAll();

  static Future setPassword(String password) async {
    final value = json.encode(password);

    await _storage.write(key: _keyPassword, value: value);
  }

  static Future<String?> getPassword() async {
    final value = await _storage.read(key: _keyPassword);

    return value == null ? '' : json.decode(value);
  }
}
