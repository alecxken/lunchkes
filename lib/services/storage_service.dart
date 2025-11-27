// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedIn() async {
    return _prefs?.getBool('is_logged_in') ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('is_logged_in', value);
  }

  static Future<void> setUsername(String username) async {
    await _prefs?.setString('username', username);
  }

  static String? getUsername() {
    return _prefs?.getString('username');
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
