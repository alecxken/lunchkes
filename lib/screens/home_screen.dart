// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lunch_provider.dart';
import '../services/storage_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/sync_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/staff_form.dart';
import '../widgets/visitor_form.dart';
import '../widgets/recent_entries.dart';
import '../widgets/pin_dialog.dart';
import 'login_screen.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final categories = ['staff', 'contract', 'visitor'];
        context.read<LunchProvider>().setCategory(
          categories[_tabController.index],
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LunchProvider>().refreshAll();
    });
  }

  Future<void> _logout() async {
    await StorageService.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _exportData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startDate =
        '${startOfMonth.year}-${startOfMonth.month.toString().padLeft(2, '0')}-${startOfMonth.day.toString().padLeft(2, '0')}';
    final endDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final provider = context.read<LunchProvider>();
    final response = await provider.exportData(
      startDate: startDate,
      endDate: endDate,
    );

    if (response.success && response.data != null) {
      // Trigger CSV download
      final csvData = response.data['csv'] ?? '';
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'lunch_records_${now.year}_${now.month}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        _showSnackBar('CSV exported successfully');
      }
    } else {
      if (mounted) {
        _showSnackBar(response.message ?? 'Export failed', isError: true);
      }
    }
  }

  bool _isAdmin() {
    final username = StorageService.getUsername();
    // Admin check - customize based on your admin usernames
    return username != null &&
        (username.toLowerCase() == 'admin' ||
            username.toLowerCase().contains('admin'));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF669438),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleValidation(String idNo, String category) async {
    final provider = context.read<LunchProvider>();

    // Check if already served
    final checkResponse = await provider.checkLunch(idNo, category);
    if (checkResponse.success && checkResponse.data?['has_lunch'] == true) {
      final record = checkResponse.data['record'];
      _showAlreadyServedDialog(record['name'], record['time']);
      return;
    }

    // Find staff
    final findResponse = await provider.findStaff(idNo);
    if (!findResponse.success) {
      _showSnackBar(findResponse.message ?? 'ID not found', isError: true);
      return;
    }

    final staffName = findResponse.data['name'];

    // Show PIN dialog
    if (mounted) {
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PinDialog(staffName: staffName),
      );

      if (pin != null) {
        final verifyResponse = await provider.verifyPin(idNo, pin);
        if (verifyResponse.success) {
          final recordResponse = await provider.recordLunch(
            category: category,
            name: staffName,
          );
          if (recordResponse.success) {
            _showSuccessDialog(staffName);
          } else {
            _showSnackBar(
              recordResponse.message ?? 'Failed to record',
              isError: true,
            );
          }
        } else {
          _showSnackBar('Invalid PIN', isError: true);
        }
      }
    }
  }

  Future<void> _handleVisitorRegistration(
    String host,
    String name,
    String company,
  ) async {
    final provider = context.read<LunchProvider>();

    // Check if already served
    final checkResponse = await provider.checkLunch(name, 'visitor');
    if (checkResponse.success && checkResponse.data?['has_lunch'] == true) {
      final record = checkResponse.data['record'];
      _showAlreadyServedDialog(record['name'], record['time']);
      return;
    }

    final response = await provider.recordLunch(
      category: 'visitor',
      name: name,
      comments: 'Visiting: $host | Company: $company',
    );

    if (response.success) {
      _showSuccessDialog(name);
    } else {
      _showSnackBar(response.message ?? 'Failed to register', isError: true);
    }
  }

  void _showSuccessDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFBED600).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 50,
                color: Color(0xFF669438),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF669438),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Lunch recorded successfully'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyServedDialog(String name, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, size: 50, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            const Text(
              'Already Served',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF669438),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Already served today'),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                'Time: $time',
                style: const TextStyle(
                  color: Color(0xFF0082BB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0082BB), Color(0xFF005B82)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lunch Validation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () =>
                          context.read<LunchProvider>().refreshAll(),
                    ),
                    if (_isAdmin())
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: _exportData,
                        tooltip: 'Export to CSV',
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),

              // Stats
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StatsCard(),
              ),
              const SizedBox(height: 12),

              // Sync Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SyncBar(),
              ),
              const SizedBox(height: 12),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CategoryTabs(controller: _tabController),
              ),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Staff Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            StaffForm(
                              category: 'staff',
                              title: 'Staff Validation',
                              icon: Icons.badge,
                              onSubmit: (idNo) =>
                                  _handleValidation(idNo, 'staff'),
                            ),
                            const SizedBox(height: 16),
                            const RecentEntries(),
                          ],
                        ),
                      ),
                      // Contract Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            StaffForm(
                              category: 'contract',
                              title: 'Contract Staff',
                              icon: Icons.description,
                              onSubmit: (idNo) =>
                                  _handleValidation(idNo, 'contract'),
                            ),
                            const SizedBox(height: 16),
                            const RecentEntries(),
                          ],
                        ),
                      ),
                      // Visitor Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            VisitorForm(onSubmit: _handleVisitorRegistration),
                            const SizedBox(height: 16),
                            const RecentEntries(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Powered by Ecobank Technology',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
