import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static SharedPreferences? _preferences;

  static const _uid = 'userid';
  static const _email = 'email';
  static const _walletid = 'walletid';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setId(String uid) async {
    print('userid ' + uid);
    await _preferences?.setString(_uid, uid);
  }

  static String? getId() {
    return _preferences?.getString(_uid);
  }

  static Future removeId() async {
    await _preferences?.remove(_uid);
  }

  static Future setEmail(String email) async {
    print('email ' + email);
    await _preferences?.setString(_email, email);
  }

  static String? getEmail() {
    return _preferences?.getString(_email);
  }

  static Future removeEmail() async {
    await _preferences?.remove(_email);
  }

  static Future setWalletID(String walletid) async {
    await _preferences?.setString(_walletid, walletid);
  }

  static String? getWalletID() {
    return _preferences?.getString(_walletid);
  }

  static Future removeWalletID() async {
    await _preferences?.remove(_walletid);
  }
}
