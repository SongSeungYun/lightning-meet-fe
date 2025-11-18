import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<void> signup({
    required String loginId,
    required String password,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/signup');
    final body = {
      'loginId': loginId,
      'password': password,
      'email': email,
    };

    print('📡 [POST] $uri');
    print('📦 요청 데이터: $body');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('📩 응답 코드: ${response.statusCode}');
    print('📨 응답 바디: ${response.body}');
  }

  static Future<void> login({
    required String loginId,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final body = {
      'loginId': loginId,
      'password': password,
    };

    print('📡 [POST] $uri');
    print('📦 요청 데이터: $body');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('📩 응답 코드: ${response.statusCode}');
    print('📨 응답 바디: ${response.body}');
  }
}
