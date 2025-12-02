import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightning_meet_fe/data/models/meeting_model.dart'; // Package import
import 'auth_service.dart';
import 'user_service.dart';

class MeetingService {
  final String _baseUrl = "http://localhost:8080/api";
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Future<List<Meeting>> getMeetings() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/meetings'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = body['data'];
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  Future<Meeting> getMeetingDetail(int meetingId) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/meetings/$meetingId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      return Meeting.fromJson(body['data']);
    } else {
      throw Exception('Failed to load meeting detail');
    }
  }

  Future<void> createMeeting({
    required String title,
    required String content,
    required String region,
    required String location,
    String? keywords,
    required int maxParticipants,
    required DateTime time,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to create a meeting.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/meetings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'content': content,
        'region': region,
        'location': location,
        'keywords': keywords,
        'maxParticipants': maxParticipants,
        'time': time.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create meeting');
    }
  }

  Future<void> updateMeeting({
    required int meetingId,
    String? title,
    String? content,
    String? region,
    String? location,
    String? keywords,
    int? maxParticipants,
    DateTime? time,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to update a meeting.');
    }

    final Map<String, dynamic> updateData = {};
    if (title != null) updateData['title'] = title;
    if (content != null) updateData['content'] = content;
    if (region != null) updateData['region'] = region;
    if (location != null) updateData['location'] = location;
    if (keywords != null) updateData['keywords'] = keywords;
    if (maxParticipants != null) updateData['maxParticipants'] = maxParticipants;
    if (time != null) updateData['time'] = time.toIso8601String();

    final response = await http.put(
      Uri.parse('$_baseUrl/meetings/$meetingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update meeting');
    }
  }

  Future<void> joinMeeting(int meetingId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to join a meeting.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/meetings/$meetingId/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to join meeting');
    }
  }

  Future<void> leaveMeeting(int meetingId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to leave a meeting.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/meetings/$meetingId/leave'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to leave meeting');
    }
  }

  Future<List<Meeting>> getMyCreatedMeetings() async {
    final user = await _userService.getMe(); // Get current user
    if (user == null) {
      throw Exception('User not logged in or profile not found.');
    }
    final allMeetings = await getMeetings(); // Get all meetings
    return allMeetings.where((meeting) => meeting.hostId == user.id).toList(); // Filter
  }

  Future<List<Meeting>> getMyParticipatingMeetings() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to get participating meetings.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/meetings/my-participating'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = body['data'];
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load participating meetings');
    }
  }
}
