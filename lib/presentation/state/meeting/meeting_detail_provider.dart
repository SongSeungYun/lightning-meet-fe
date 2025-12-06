import 'package:flutter/material.dart';
import '../../../data/models/meeting_model.dart';
import '../../../data/services/meeting_service.dart';

class MeetingDetailProvider with ChangeNotifier {
  final MeetingService _meetingService = MeetingService();
  Meeting? _meeting;
  Meeting? get meeting => _meeting;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMeetingDetail(int meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meeting = await _meetingService.getMeetingDetail(meetingId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinMeeting(int meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _meetingService.joinMeeting(meetingId);
      // Refresh detail after joining
      await fetchMeetingDetail(meetingId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveMeeting(int meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _meetingService.leaveMeeting(meetingId);
      // Refresh detail after leaving
      await fetchMeetingDetail(meetingId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
