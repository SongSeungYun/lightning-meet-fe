import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meeting_model.dart';
import 'auth_service.dart';

class MeetingService {
  final String _baseUrl = "http://localhost:8080/api";
  final AuthService _authService = AuthService();

  Future<List<Meeting>> getMeetings() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/meetings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = body['data'];
      // We need to create the Meeting model first.
      // For now, let's assume it exists and has a fromJson factory.
      // This will cause an error until we create the model.
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meetings');
    }
  }
}
