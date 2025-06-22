// lib/services/http_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl =
      "https://7398-45-119-114-220.ngrok-free.app/api/v1";

  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(
        'Request failed with status: ${response.statusCode}',
        uri: response.request?.url,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;

  HttpException(this.message, {this.uri});

  @override
  String toString() =>
      'HttpException: $message${uri != null ? ', URI: $uri' : ''}';
}
