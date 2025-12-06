import 'package:flutter_test/flutter_test.dart';
import 'package:lightning_meet_fe/data/models/meeting_model.dart';
import 'package:lightning_meet_fe/data/models/page_response_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:lightning_meet_fe/data/services/meeting_service.dart';
import 'package:lightning_meet_fe/presentation/state/meeting/meeting_provider.dart';

import 'meeting_provider_test.mocks.dart';

@GenerateMocks([MeetingService])
void main() {
  late MeetingProvider meetingProvider;
  late MockMeetingService mockMeetingService;

  setUp(() {
    mockMeetingService = MockMeetingService();
    meetingProvider = MeetingProvider(meetingService: mockMeetingService);
  });

  group('MeetingProvider', () {
    test('initial state is correct', () {
      expect(meetingProvider.meetings, isEmpty);
      expect(meetingProvider.imminentMeetings, isEmpty);
      expect(meetingProvider.isLoading, isFalse);
      expect(meetingProvider.errorMessage, isNull);
    });

    test('fetchInitialMeetings populates meetings and imminentMeetings on success', () async {
      final mockImminentMeetings = [Meeting(id: 101, title: 'Imminent Meeting', content: '', region: '', location: '', maxParticipants: 5, currentParticipants: 1, hostId: 1, time: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now())];
      final mockPageResponse = PageResponse<Meeting>(content: [Meeting(id: 1, title: 'Meeting 1', content: '', region: '', location: '', maxParticipants: 5, currentParticipants: 1, hostId: 1, time: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now())], pageNumber: 0, pageSize: 10, totalPages: 1, totalElements: 1, last: true);

      when(mockMeetingService.getImminentMeetings())
          .thenAnswer((_) async => mockImminentMeetings);
      when(mockMeetingService.getMeetings(page: 0, size: 10))
          .thenAnswer((_) async => mockPageResponse);

      await meetingProvider.fetchInitialMeetings();

      expect(meetingProvider.imminentMeetings, mockImminentMeetings);
      expect(meetingProvider.meetings, mockPageResponse.content);
      expect(meetingProvider.isLoading, isFalse);
      expect(meetingProvider.errorMessage, isNull);

      verify(mockMeetingService.getImminentMeetings()).called(1);
      verify(mockMeetingService.getMeetings(page: 0, size: 10)).called(1);
    });

    test('fetchInitialMeetings sets errorMessage on failure', () async {
      final exception = Exception('Failed to load');
      when(mockMeetingService.getImminentMeetings()).thenThrow(exception);
      when(mockMeetingService.getMeetings(page: 0, size: 10))
          .thenAnswer((_) async => PageResponse<Meeting>(content: [], pageNumber: 0, pageSize: 10, totalPages: 0, totalElements: 0, last: true));

      await meetingProvider.fetchInitialMeetings();

      expect(meetingProvider.errorMessage, isNotNull);
      expect(meetingProvider.isLoading, isFalse);
    });
  });
}
