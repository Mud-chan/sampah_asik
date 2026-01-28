import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUsername = 'username';
  static const String _keyLoginTime = 'login_time';

  /// Simpan login
  static Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setInt(
      _keyLoginTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Cek masih login (2 hari)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_keyLoginTime);

    if (loginTime == null) return false;

    final now = DateTime.now();
    final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);

    return now.difference(loginDate).inDays < 2;
  }

  /// Ambil username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
