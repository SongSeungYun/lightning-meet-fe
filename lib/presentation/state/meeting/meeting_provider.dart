import 'package:flutter/material.dart';
import '../../../data/models/meeting_model.dart';
import '../../../data/services/meeting_service.dart';

class MeetingProvider with ChangeNotifier {
  final MeetingService _meetingService = MeetingService();
  List<Meeting> _fullMeetingList = []; // Store the original full list
  List<Meeting> _meetings = []; // This will hold the filtered list
  List<Meeting> get meetings => _meetings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMeetings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fullMeetingList = await _meetingService.getMeetings();
      _meetings = _fullMeetingList; // Initially, display all meetings
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchMeetings({String keyword = '', String category = '', String region = ''}) {
    _isLoading = true;
    notifyListeners();

    List<Meeting> filteredList = _fullMeetingList;

    if (keyword.isNotEmpty) {
      filteredList = filteredList
          .where((m) =>
              m.title.toLowerCase().contains(keyword.toLowerCase()) ||
              m.content.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    if (category.isNotEmpty) {
      filteredList = filteredList
          .where((m) =>
              m.keywords?.toLowerCase().contains(category.toLowerCase()) ?? false)
          .toList();
    }

    if (region.isNotEmpty) {
      filteredList = filteredList
          .where((m) =>
              m.region.toLowerCase().contains(region.toLowerCase()))
          .toList();
    }

    _meetings = filteredList;
    _isLoading = false;
    notifyListeners();
  }
}
