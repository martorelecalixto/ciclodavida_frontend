import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fctoken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(Uri url) async {
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(Uri url, {Object? body}) async {
    final headers = await _getHeaders();
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> put(Uri url, {Object? body}) async {
    final headers = await _getHeaders();
    return http.put(url, headers: headers, body: body);
  }

  static Future<http.Response> delete(Uri url) async {
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }
}
