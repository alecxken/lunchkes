// lib/utils/file_export_mobile.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadCSVMobile(String csvData, String filename) async {
  try {
    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$filename';

    // Write CSV data to file
    final file = File(filePath);
    await file.writeAsString(csvData);

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Lunch Records Export',
    );
  } catch (e) {
    throw Exception('Failed to export CSV: $e');
  }
}

// Stub for web
Future<void> downloadCSVWeb(String csvData, String filename) async {
  throw UnsupportedError('Web export should use file_export_web.dart');
}
