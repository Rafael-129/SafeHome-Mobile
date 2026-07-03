import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const String _isAuthenticatedKey = 'safehome_mobile_is_authenticated';
  static const String _usernameKey = 'safehome_mobile_username';

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<bool> login({required String username, required String password}) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    final success = trimmedUsername.isNotEmpty && trimmedPassword.isNotEmpty;
    if (!success) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, true);
    await prefs.setString(_usernameKey, trimmedUsername);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isAuthenticatedKey);
    await prefs.remove(_usernameKey);
  }
}
