import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightning_meet_fe/data/models/user_model.dart'; // Package import
import 'auth_service.dart';

class UserService {
  final String _baseUrl = "http://localhost:8080/api";
  final AuthService _authService = AuthService();

  Future<User> getMe() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      return User.fromJson(body['data']);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> updateUser({
    required int userId,
    String? nickname,
    String? region,
    String? interests,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }

    final Map<String, dynamic> updateData = {};
    if (nickname != null) updateData['nickname'] = nickname;
    if (region != null) updateData['region'] = region;
    if (interests != null) updateData['interests'] = interests;

    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user profile');
    }
  }
}
