// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://merchantchargeback.ecobank.com/api/lunch';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Authentication
  static Future<ApiResponse> login(String username, String pin) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-pin'),
            headers: headers,
            body: json.encode({'username': username, 'pin': pin}),
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Find Staff
  static Future<ApiResponse> findStaff(String idNo, String category) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/find?id_no=$idNo&category=$category'),
            headers: headers,
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Verify PIN
  static Future<ApiResponse> verifyPin(String idNo, String pin) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-pin'),
            headers: headers,
            body: json.encode({'id_no': idNo, 'pin': pin}),
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Check Lunch Status
  static Future<ApiResponse> checkLunch(String name, String category) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/check?name=${Uri.encodeComponent(name)}&category=$category',
            ),
            headers: headers,
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Store Lunch Record
  static Future<ApiResponse> storeLunch(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/store'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Get Today's Summary
  static Future<ApiResponse> getSummary() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/summary'), headers: headers)
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Get Recent Records
  static Future<ApiResponse> getRecords({int perPage = 10}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/records?per_page=$perPage'),
            headers: headers,
          )
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Sync to Server
  static Future<ApiResponse> syncToServer() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/sync'), headers: headers)
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Get Sync Status
  static Future<ApiResponse> getSyncStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/sync-status'), headers: headers)
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }

  // Load Master Data
  static Future<ApiResponse> loadMasterData() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/load-master'), headers: headers)
          .timeout(timeout);

      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.error('Connection failed: $e');
    }
  }
}

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode = 200,
  });

  factory ApiResponse.fromResponse(http.Response response) {
    final body = json.decode(response.body);
    return ApiResponse(
      success:
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['status'] == 'success',
      message: body['message'],
      data: body['data'] ?? body,
      statusCode: response.statusCode,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(success: false, message: message, statusCode: 500);
  }
}
