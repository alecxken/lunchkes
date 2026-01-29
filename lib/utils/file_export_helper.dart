// lib/utils/file_export_helper.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'file_export_mobile.dart' if (dart.library.html) 'file_export_web.dart';

class FileExportHelper {
  static Future<void> downloadCSV(String csvData, String filename) async {
    if (kIsWeb) {
      return downloadCSVWeb(csvData, filename);
    } else {
      return downloadCSVMobile(csvData, filename);
    }
  }
}
