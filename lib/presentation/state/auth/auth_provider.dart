import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    print("AuthProvider: Checking login status...");
    String? token = await _authService.getToken();
    _isLoggedIn = token != null;
    _isLoading = false;
    print("AuthProvider: Login status checked. isLoggedIn: $_isLoggedIn");
    notifyListeners();
  }

  Future<void> login(String loginId, String password) async {
    print("AuthProvider: Attempting to log in...");
    try {
      await _authService.login(loginId: loginId, password: password);
      _isLoggedIn = true;
      print("AuthProvider: Login successful. Notifying listeners...");
      notifyListeners();
      print("AuthProvider: Listeners notified.");
    } catch (e) {
      print("AuthProvider: An error occurred during login: $e");
      // Re-throw the exception so the UI can catch it and show an error message.
      rethrow;
    }
  }

  void logout() async {
    print("AuthProvider: Logging out...");
    await _authService.logout();
    _isLoggedIn = false;
    print("AuthProvider: Logged out. Notifying listeners...");
    notifyListeners();
  }
}
