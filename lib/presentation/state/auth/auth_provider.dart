import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoading = true; // 앱 시작 시 로딩 상태
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token = await _authService.getToken();
    _isLoggedIn = token != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String loginId, String password) async {
    await _authService.login(loginId: loginId, password: password);
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
