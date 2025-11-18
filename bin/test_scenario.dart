import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const baseUrl = 'http://127.0.0.1:8080/api';

void printHeader(String title) {
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📍 $title');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

void printRequest(String method, String endpoint, [Map<String, dynamic>? body]) {
  stdout.writeln('📡 [$method] $endpoint');
  if (body != null) stdout.writeln('📦 요청: ${jsonEncode(body)}');
}

void printResponse(http.Response res) {
  stdout.writeln('📨 응답 (${res.statusCode}): ${res.body}');
}

void printSuccess(String msg) => stdout.writeln('✅ $msg');
void printFail(String msg) => stdout.writeln('❌ $msg');

Future<void> main() async {
  print('\n🚀 LightningMeet 전체 통합 시나리오 시작');
  print('--------------------------------------------');

  // 🟩 User A 회원가입 + 로그인
  printHeader('1️⃣ User A 회원가입 및 로그인');
  await signup('userA', '1234', 'userA@example.com', '유저A');
  final aAccess = await login('userA', '1234');
  printSuccess('User A 로그인 완료');

  // 🟦 User A 모임 생성
  printHeader('2️⃣ User A 모임 생성');
  final meetingId = await createMeeting(
    token: aAccess,
    title: 'Flutter 스터디',
    content: '플러터 기초를 함께 학습하는 모임입니다.',
    region: '서울',
    maxParticipants: 5,
    eventAt: '2025-11-12T18:00:00',
  );
  printSuccess('User A 모임 생성 완료 → ID=$meetingId');

  // 🟨 User B 회원가입 + 로그인
  printHeader('3️⃣ User B 회원가입 및 로그인');
  await signup('userB', '1234', 'userB@example.com', '유저B');
  final bAccess = await login('userB', '1234');
  printSuccess('User B 로그인 완료');

  // 🟧 User B 모임 참여
  printHeader('4️⃣ User B 모임 참여');
  await joinMeeting(token: bAccess, meetingId: meetingId);
  printSuccess('User B 모임 참여 완료');

  // 🟥 User B 모임 탈퇴
  printHeader('5️⃣ User B 모임 탈퇴');
  await leaveMeeting(token: bAccess, meetingId: meetingId);
  printSuccess('User B 모임 탈퇴 완료');

  // ⚫ User A 모임 삭제
  printHeader('6️⃣ User A 모임 삭제');
  await deleteMeeting(token: aAccess, meetingId: meetingId);
  printSuccess('User A 모임 삭제 완료');

  print('\n🎉 모든 테스트 시나리오 성공적으로 완료!\n');
}

// ─────────────────────────── 요청 함수들 ───────────────────────────

Future<void> signup(String id, String pw, String email, String nickname) async {
  final uri = Uri.parse('$baseUrl/auth/signup');
  final body = {
    'loginId': id,
    'password': pw,
    'email': email,
    'nickname': nickname,
  };

  printRequest('POST', '/auth/signup', body);
  try {
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    printResponse(res);

    if (res.statusCode == 200) {
      printSuccess('User $id 회원가입 성공');
    } else if (res.statusCode == 409) {
      printFail('이미 존재하는 아이디 ($id), 기존 계정 사용');
    } else {
      printFail('회원가입 실패 (${res.statusCode})');
    }
  } catch (e) {
    printFail('회원가입 중 오류 발생: $e');
  }
}

Future<String> login(String id, String pw) async {
  final uri = Uri.parse('$baseUrl/auth/login');
  final body = {'loginId': id, 'password': pw};

  printRequest('POST', '/auth/login', body);
  try {
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    printResponse(res);
    final json = jsonDecode(res.body);

    if (res.statusCode == 200 && json['data'] != null) {
      return json['data']['accessToken'];
    } else {
      printFail('로그인 실패 (${res.statusCode})');
      exit(1);
    }
  } catch (e) {
    printFail('로그인 중 오류 발생: $e');
    exit(1);
  }
}

Future<int> createMeeting({
  required String token,
  required String title,
  required String content,
  required String region,
  required int maxParticipants,
  required String eventAt,
}) async {
  final uri = Uri.parse('$baseUrl/meetings');
  final body = {
    'title': title,
    'content': content,
    'region': region,
    'maxParticipants': maxParticipants,
    'eventAt': eventAt,
  };

  printRequest('POST', '/meetings', body);
  final res = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );
  printResponse(res);
  final json = jsonDecode(res.body);
  return json['data']['id'];
}

Future<void> joinMeeting({required String token, required int meetingId}) async {
  final uri = Uri.parse('$baseUrl/meetings/$meetingId/join');
  printRequest('POST', '/meetings/$meetingId/join');
  final res = await http.post(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  );
  printResponse(res);
}

Future<void> leaveMeeting({required String token, required int meetingId}) async {
  final uri = Uri.parse('$baseUrl/meetings/$meetingId/leave');
  printRequest('POST', '/meetings/$meetingId/leave');
  final res = await http.post(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
  );
  printResponse(res);
}

Future<void> deleteMeeting({required String token, required int meetingId}) async {
  final uri = Uri.parse('$baseUrl/meetings/$meetingId');
  printRequest('DELETE', '/meetings/$meetingId');
  final res = await http.delete(uri, headers: {'Authorization': 'Bearer $token'});
  printResponse(res);
}
