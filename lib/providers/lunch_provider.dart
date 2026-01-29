// lib/providers/lunch_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class LunchProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, int> _summary = {
    'staff': 0,
    'contract': 0,
    'visitor': 0,
    'consultant': 0,
  };
  int _total = 0;
  int _pending = 0;
  int _synced = 0;
  String? _lastSync;
  List<dynamic> _recentRecords = [];
  String _selectedCategory = 'staff';

  bool get isLoading => _isLoading;
  Map<String, int> get summary => _summary;
  int get total => _total;
  int get pending => _pending;
  int get synced => _synced;
  String? get lastSync => _lastSync;
  List<dynamic> get recentRecords => _recentRecords;
  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadSummary() async {
    final response = await ApiService.getSummary();
    if (response.success && response.data != null) {
      final data = response.data;
      _summary = {
        'staff': data['by_category']?['staff'] ?? 0,
        'contract': data['by_category']?['contract'] ?? 0,
        'visitor': data['by_category']?['visitor'] ?? 0,
        'consultant': data['by_category']?['consultant'] ?? 0,
      };
      _total = data['total'] ?? 0;
      _pending = data['pending'] ?? 0;
      _synced = data['synced'] ?? 0;
      notifyListeners();
    }
  }

  Future<void> loadSyncStatus() async {
    final response = await ApiService.getSyncStatus();
    if (response.success && response.data != null) {
      _pending = response.data['pending'] ?? 0;
      _synced = response.data['synced'] ?? 0;
      _lastSync = response.data['last_sync'];
      notifyListeners();
    }
  }

  Future<void> loadRecentRecords() async {
    final response = await ApiService.getRecords(perPage: 10);
    if (response.success && response.data != null) {
      _recentRecords = response.data is List ? response.data : [];
      notifyListeners();
    }
  }

  Future<ApiResponse> findStaff(String idNo) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.findStaff(idNo, _selectedCategory);

    _isLoading = false;
    notifyListeners();

    return response;
  }

  Future<ApiResponse> checkLunch(String name, String category) async {
    return await ApiService.checkLunch(name, category);
  }

  Future<ApiResponse> verifyPin(String idNo, String pin) async {
    return await ApiService.verifyPin(idNo, pin);
  }

  Future<ApiResponse> recordLunch({
    required String category,
    required String name,
    String? comments,
    String? verifiedBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final response = await ApiService.storeLunch({
      'category': category,
      'name': name,
      'time':
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'comments': comments,
      'verified_by': verifiedBy,
    });

    _isLoading = false;

    if (response.success) {
      await loadSummary();
      await loadRecentRecords();
      await loadSyncStatus();
    }

    notifyListeners();
    return response;
  }

  Future<ApiResponse> syncToServer() async {
    _isLoading = true;
    notifyListeners();

    // Use improved sync with retry
    final response = await ApiService.syncWithRetry(maxRetries: 3);

    _isLoading = false;

    if (response.success) {
      // Clear local cache after successful sync
      await StorageService.clearAllCache();
      await StorageService.setLastSyncTime();

      // Check storage and cleanup if needed
      final isOverLimit = await StorageService.isStorageOverLimit();
      if (isOverLimit) {
        await StorageService.cleanupOldData();
      }

      await loadSyncStatus();
      await loadRecentRecords();
    }

    notifyListeners();
    return response;
  }

  // Export data to CSV
  Future<ApiResponse> exportData({
    String? startDate,
    String? endDate,
    String? category,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.exportData(
      startDate: startDate,
      endDate: endDate,
      category: category,
    );

    _isLoading = false;
    notifyListeners();

    return response;
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([loadSummary(), loadSyncStatus(), loadRecentRecords()]);

    _isLoading = false;
    notifyListeners();
  }
}
