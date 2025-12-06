import 'package:flutter/material.dart';
import '../../../data/models/meeting_model.dart';
import '../../../data/models/page_response_model.dart'; // Added this import
import '../../../data/services/meeting_service.dart';

class MeetingProvider with ChangeNotifier {
  final MeetingService _meetingService;

  MeetingProvider({MeetingService? meetingService})
      : _meetingService = meetingService ?? MeetingService();
  List<Meeting> _meetings = [];
  List<Meeting> get meetings => _meetings;

  List<Meeting> _imminentMeetings = [];
  List<Meeting> get imminentMeetings => _imminentMeetings;

  // Pagination state
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool isSearchActive = false;

  Future<void> fetchInitialMeetings() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _meetingService.getImminentMeetings(),
        _meetingService.getMeetings(page: 0, size: _pageSize)
      ]);

      _imminentMeetings = results[0] as List<Meeting>;
      final pageResponse = results[1] as PageResponse<Meeting>;

      _meetings = pageResponse.content;
      _fullMeetingList = pageResponse.content;
      _currentPage = 1;
      _hasMore = !pageResponse.last;
      isSearchActive = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchMeetingsInternal({int page = 0, int size = 10, String? region}) async {
    try {
      final pageResponse = await _meetingService.getMeetings(page: page, size: size, region: region);
      if (page == 0) { // If fetching the first page, replace existing meetings
        _meetings = pageResponse.content;
        _fullMeetingList = pageResponse.content;
      } else { // Otherwise, add to existing meetings
        _meetings.addAll(pageResponse.content);
        _fullMeetingList.addAll(pageResponse.content);
      }
      _currentPage = pageResponse.pageNumber + 1;
      _hasMore = !pageResponse.last;
      isSearchActive = false;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> fetchMoreMeetings() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await _fetchMeetingsInternal(page: _currentPage, size: _pageSize);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  List<Meeting> _fullMeetingList = [];
  List<Meeting> get fullMeetingList => _fullMeetingList;

  void searchMeetings({String keyword = '', String category = '', String region = ''}) {
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
    isSearchActive = true;
    notifyListeners();
  }

  void clearSearch() {
    _meetings = _fullMeetingList;
    isSearchActive = false;
    notifyListeners();
  }
}