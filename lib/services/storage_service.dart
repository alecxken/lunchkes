// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;
  static const int maxStorageMB = 100;
  static const int dataRetentionDays = 90; // 3 months

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

  // Cache management
  static Future<void> cacheData(String key, dynamic data) async {
    final json = jsonEncode({
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs?.setString('cache_$key', json);
  }

  static dynamic getCachedData(String key) {
    final cached = _prefs?.getString('cache_$key');
    if (cached == null) return null;

    try {
      final json = jsonDecode(cached);
      final timestamp = DateTime.parse(json['timestamp']);
      final age = DateTime.now().difference(timestamp).inDays;

      // Auto-delete data older than retention period
      if (age > dataRetentionDays) {
        clearCache(key);
        return null;
      }

      return json['data'];
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCache(String key) async {
    await _prefs?.remove('cache_$key');
  }

  static Future<void> clearAllCache() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await _prefs?.remove(key);
      }
    }
  }

  // Storage size management
  static Future<int> getStorageSizeBytes() async {
    int totalSize = 0;
    final keys = _prefs?.getKeys() ?? {};

    for (final key in keys) {
      final value = _prefs?.get(key);
      if (value != null) {
        totalSize += value.toString().length * 2; // UTF-16 approximation
      }
    }

    return totalSize;
  }

  static Future<double> getStorageSizeMB() async {
    final bytes = await getStorageSizeBytes();
    return bytes / (1024 * 1024);
  }

  static Future<bool> isStorageOverLimit() async {
    final sizeMB = await getStorageSizeMB();
    return sizeMB > maxStorageMB;
  }

  static Future<void> cleanupOldData() async {
    final keys = _prefs?.getKeys() ?? {};

    for (final key in keys) {
      if (key.startsWith('cache_')) {
        final cached = _prefs?.getString(key);
        if (cached != null) {
          try {
            final json = jsonDecode(cached);
            final timestamp = DateTime.parse(json['timestamp']);
            final age = DateTime.now().difference(timestamp).inDays;

            if (age > dataRetentionDays) {
              await _prefs?.remove(key);
            }
          } catch (e) {
            // Invalid cache entry, remove it
            await _prefs?.remove(key);
          }
        }
      }
    }
  }

  static Future<void> setLastSyncTime() async {
    await _prefs?.setString('last_sync', DateTime.now().toIso8601String());
  }

  static DateTime? getLastSyncTime() {
    final timestamp = _prefs?.getString('last_sync');
    if (timestamp == null) return null;
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }
}
