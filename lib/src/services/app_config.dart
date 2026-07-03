import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _baseUrlKey = 'safehome_mobile_base_url';
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
  }

  Future<void> setBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, value.trim());
  }
}
