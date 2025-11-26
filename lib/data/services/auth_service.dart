import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = "http://10.0.2.2:8080/api/auth";
  final _storage = const FlutterSecureStorage();

  Future<void> signup({ required String loginId, required String password, required String email, required String nickname }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'loginId': loginId, 'password': password, 'email': email, 'nickname': nickname}),
    );
    if (response.statusCode != 200) throw Exception('회원가입 실패');
  }

  Future<void> login({ required String loginId, required String password }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'loginId': loginId, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      await _storage.write(key: 'accessToken', value: data['accessToken']);
    } else {
      throw Exception('로그인 실패');
    }
  }

  Future<void> logout() async => await _storage.delete(key: 'accessToken');
  Future<String?> getToken() async => await _storage.read(key: 'accessToken');
}
