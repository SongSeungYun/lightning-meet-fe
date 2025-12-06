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
  print('\n🚀 LightningMeet 현실적인 시나리오 시작');
  print('--------------------------------------------');

  // 🟩 User A (모임 주최자)
  printHeader('1️⃣ 모임 주최자(운동매니아) 생성 및 로그인');
  await signup('running_lover', '1234', 'runner@example.com', '운동매니아');
  final runnerAccess = await login('running_lover', '1234');
  printSuccess('운동매니아 로그인 완료');

  printHeader('2️⃣ 운동매니아, "주말 아침 테니스" 모임 생성');
  final tennisMeetingId = await createMeeting(
    token: runnerAccess,
    title: '주말 아침 테니스 같이 치실 분! (초보 환영)',
    content: '토요일 아침 9시에 서울숲 테니스장에서 같이 테니스 치실 분 구합니다. 실력은 상관없고, 즐겁게 운동하는 게 목적이에요. 라켓 없으시면 하나 빌려드릴 수 있습니다. 끝나고 근처에서 브런치 하실 분들은 같이 가요!',
    region: '서울 성동구',
    maxParticipants: 4,
    eventAt: '2025-12-20T09:00:00',
  );
  printSuccess('테니스 모임 생성 완료 → ID=$tennisMeetingId');

  // 🟦 User B (첫 번째 참가자)
  printHeader('3️⃣ 첫 번째 참가자(코딩꿈나무) 생성 및 로그인');
  await signup('coder_wannabe', '1234', 'coder@example.com', '코딩꿈나무');
  final coderAccess = await login('coder_wannabe', '1234');
  printSuccess('코딩꿈나무 로그인 완료');

  printHeader('4️⃣ 코딩꿈나무, "주말 아침 테니스" 모임 참여');
  await joinMeeting(token: coderAccess, meetingId: tennisMeetingId);
  printSuccess('코딩꿈나무, 테니스 모임 참여 완료');

  // 🟨 User C (두 번째 참가자)
  printHeader('5️⃣ 두 번째 참가자(산책러버) 생성 및 로그인');
  await signup('walking_lover', '1234', 'walker@example.com', '산책러버');
  final walkerAccess = await login('walking_lover', '1234');
  printSuccess('산책러버 로그인 완료');

  printHeader('6️⃣ 산책러버, "주말 아침 테니스" 모임 참여');
  await joinMeeting(token: walkerAccess, meetingId: tennisMeetingId);
  printSuccess('산책러버, 테니스 모임 참여 완료');

  // 🟧 User D (다른 모임 주최자)
  printHeader('7️⃣ 다른 모임 주최자(게으른천재) 생성 및 로그인');
  await signup('lazy_genius', '1234', 'genius@example.com', '게으른천재');
  final geniusAccess = await login('lazy_genius', '1234');
  printSuccess('게으른천재 로그인 완료');

  printHeader('8️⃣ 게으른천재, "코딩 스터디" 모임 생성');
  final codingMeetingId = await createMeeting(
    token: geniusAccess,
    title: '강남역 카페에서 주말 코딩 스터디 하실 분',
    content: '이번 주 일요일 오후 2시에 같이 모여서 코딩/사이드 프로젝트 하실 분 구합니다. 서로 동기부여도 하고, 막히는 부분 있으면 이야기도 나눠봐요. 자바, 코틀린, 스프링부트 하시는 분이면 더 좋습니다.',
    region: '서울 강남구',
    maxParticipants: 5,
    eventAt: '2025-12-21T14:00:00',
  );
  printSuccess('코딩 스터디 모임 생성 완료 → ID=$codingMeetingId');

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
