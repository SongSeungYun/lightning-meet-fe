import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightning_meet_fe/data/models/meeting_model.dart';
import 'package:collection/collection.dart'; // Add this import

// 이 스크립트는 Flutter 플러그인(secure_storage)에 대한 의존성을 제거하고,
// 순수 Dart 환경에서 실행될 수 있도록 자체적으로 http 통신을 수행합니다.
// 실행 방법: dart run bin/demo_test_scenario.dart

const String _baseUrl = "http://localhost:8080/api";
String? _inMemoryToken; // Store token in memory for the script's duration

Future<void> main() async {
  print('=============== 테스트 시나리오 데이터 생성을 시작합니다. ===============');

  final interests = {
    'running': '러닝',
    'health': '헬스',
    'coding': '코딩',
    'baduk': '바둑',
    'lol': '롤',
    'futsal': '풋살',
  };

  for (var interestEntry in interests.entries) {
    final interestEn = interestEntry.key;
    final interestKo = interestEntry.value;
    final userCount = 10;

    print('\n----- [${interestKo}] 관심사 사용자 생성 시작 (${userCount}명) -----');
    for (int i = 1; i <= userCount; i++) {
      final loginId = '${interestEn}_user$i';
      final nickname = '${interestKo}마니아$i';
      final region = i.isOdd ? '서울 강서구' : '서울 강남구';
      await _signup(loginId, '1234', '$loginId@gmail.com', nickname);
      print('✅ [${nickname}] 사용자 생성 성공. (지역: ${region})');
      await Future.delayed(const Duration(milliseconds: 50));
    }

    print('\n----- [${interestKo}] 관심사 모임 생성 시작 -----');
    Meeting? gangseoMeeting;
    Meeting? gangnamMeeting;

    final creator1Id = '${interestEn}_user1';
    final creator1Nickname = '${interestKo}마니아1';
    _inMemoryToken = await _login(creator1Id, '1234');
    if (_inMemoryToken != null) {
      gangseoMeeting = await _createMeeting(
          title: '[${interestKo}] 함께 즐겨요! (${creator1Nickname} 주최)',
          content: '${interestKo} 좋아하시는 분들 모여서 같이 즐겁게 활동해요!',
          region: '서울 강서구',
          maxParticipants: userCount ~/ 2,
          eventAt: DateTime.now().add(const Duration(days: 7)),
      );
      if(gangseoMeeting != null) {
        print('✅ [${creator1Nickname}]가 [서울 강서구]에 모임 생성 성공.');
      }
    }
    await Future.delayed(const Duration(milliseconds: 50));

    final creator2Id = '${interestEn}_user2';
    final creator2Nickname = '${interestKo}마니아2';
    _inMemoryToken = await _login(creator2Id, '1234');
    if (_inMemoryToken != null) {
      gangnamMeeting = await _createMeeting(
          title: '[${interestKo}] 초보자 환영! (${creator2Nickname} 주최)',
          content: '부담없이 오셔서 같이 즐겨요! 매너는 필수!',
          region: '서울 강남구',
          maxParticipants: userCount ~/ 2,
          eventAt: DateTime.now().add(const Duration(days: 5)),
      );
      if(gangnamMeeting != null) {
        print('✅ [${creator2Nickname}]가 [서울 강남구]에 모임 생성 성공.');
      }
    }
    await Future.delayed(const Duration(milliseconds: 50));


    print('\n----- [${interestKo}] 관심사 모임 참여 시작 -----');
    // final allMeetings = await _getMeetings(); // No longer needed
    
    for (int i = 3; i < userCount - 1; i++) { // Loop up to userCount - 2
      final participantLoginId = '${interestEn}_user$i';
      final participantNickname = '${interestKo}마니아$i';
      final Meeting? targetMeeting = i.isOdd ? gangseoMeeting : gangnamMeeting;

      if (targetMeeting == null) {
        print('⚠️ [${participantNickname}]이 참여할 모임을 찾지 못했습니다.');
        continue;
      }
      
      _inMemoryToken = await _login(participantLoginId, '1234');
      if (_inMemoryToken != null) {
        await _joinMeeting(targetMeeting.id);
        print('✅ [${participantNickname}]이(가) [${targetMeeting.title}] 모임에 참여했습니다.');
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
    print('ℹ️ [${interestKo}마니아${userCount - 1}]와 [${interestKo}마니아${userCount}]는 의도적으로 모임에 참여하지 않습니다.');
  }

  print('\n=============== 모든 테스트 시나리오 데이터 생성이 완료되었습니다. ===============');
}

// Helper functions to make direct API calls

Future<void> _signup(String loginId, String password, String email, String nickname) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'loginId': loginId, 'password': password, 'email': email, 'nickname': nickname}),
    );
     if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ _signup 실패: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('❌ _signup 실패: $e');
  }
}

Future<String?> _login(String loginId, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'loginId': loginId, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'];
      return data['accessToken'];
    } else {
       print('❌ _login 실패: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('❌ _login 실패: $e');
  }
  return null;
}

Future<Meeting?> _createMeeting({
  required String title,
  required String content,
  required String region,
  required int maxParticipants,
  required DateTime eventAt,
}) async {
  if (_inMemoryToken == null) {
    print('❌ _createMeeting 실패: Not logged in.');
    return null;
  }
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/meetings'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_inMemoryToken'},
      body: json.encode({
        'title': title,
        'content': content,
        'region': region,
        'maxParticipants': maxParticipants,
        'eventAt': eventAt.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      return Meeting.fromJson(body['data']);
    } else {
      print('❌ _createMeeting 실패: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('❌ _createMeeting 실패: $e');
  }
  return null;
}

Future<void> _joinMeeting(int meetingId) async {
  if (_inMemoryToken == null) {
    print('❌ _joinMeeting 실패: Not logged in.');
    return;
  }
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/meetings/$meetingId/join'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_inMemoryToken'},
    );
     if (response.statusCode != 200) {
      print('❌ _joinMeeting 실패: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('❌ _joinMeeting 실패: $e');
  }
}
