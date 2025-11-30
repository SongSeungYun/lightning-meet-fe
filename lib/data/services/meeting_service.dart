import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightning_meet_fe/data/models/meeting_model.dart'; // Package import
import 'auth_service.dart';
import 'user_service.dart';

class MeetingService {
  final String _baseUrl = "http://localhost:8080/api"; // Changed for script compatibility
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
    required int maxParticipants,
    required DateTime eventAt,
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
        'maxParticipants': maxParticipants,
        'eventAt': eventAt.toIso8601String(),
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
    int? maxParticipants,
    DateTime? eventAt,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required to update a meeting.');
    }

    final Map<String, dynamic> updateData = {};
    if (title != null) updateData['title'] = title;
    if (content != null) updateData['content'] = content;
    if (region != null) updateData['region'] = region;
    if (maxParticipants != null) updateData['maxParticipants'] = maxParticipants;
    if (eventAt != null) updateData['eventAt'] = eventAt.toIso8601String();

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
    // TODO: 백엔드에 현재 로그인한 사용자가 참여하는 모임 목록을 가져오는 API가 필요합니다.
    // 현재는 Meeting 모델에 참여자 목록이 없어 프론트엔드에서 필터링이 어렵습니다.
    // 임시로 모든 모임을 반환하거나, 특정 참가자 ID로 필터링하는 로직이 필요합니다.
    // 백엔드 API가 구현되면 해당 API를 호출하도록 수정해야 합니다.
    print("TODO: getMyParticipatingMeetings - Backend API needed for filtering by participant.");
    return await getMeetings(); // Placeholder: returns all meetings
  }
}
