import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';

class ProfileProvider with ChangeNotifier {
  final UserService _userService = UserService();
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getMe();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? nickname,
    String? region,
    String? interests,
  }) async {
    if (_user == null) {
      _errorMessage = "User not loaded.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUser(
        userId: _user!.id,
        nickname: nickname,
        region: region,
        interests: interests,
      );
      // Refresh user data after update
      await fetchUserProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
