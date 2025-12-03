import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightning_meet_fe/data/models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  final String _baseUrl = "http://10.0.2.2:8080/api";
  final AuthService _authService = AuthService();

  Future<List<NotificationModel>> getNotifications() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = body['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
}
