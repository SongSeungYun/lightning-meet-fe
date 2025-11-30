import 'package:flutter/material.dart';
import '../../../data/models/meeting_model.dart';
import '../../../data/services/meeting_service.dart';

class MyCreatedMeetingsProvider with ChangeNotifier {
  final MeetingService _meetingService = MeetingService();
  List<Meeting> _meetings = [];
  List<Meeting> get meetings => _meetings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyCreatedMeetings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meetings = await _meetingService.getMyCreatedMeetings();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
