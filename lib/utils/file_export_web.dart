// lib/utils/file_export_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadCSVWeb(String csvData, String filename) async {
  try {
    final blob = html.Blob([csvData], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    throw Exception('Failed to export CSV: $e');
  }
}

// Stub for mobile
Future<void> downloadCSVMobile(String csvData, String filename) async {
  throw UnsupportedError('Mobile export should use file_export_mobile.dart');
}
