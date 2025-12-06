import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Optimistically update the UI
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          type: _notifications[index].type,
          message: _notifications[index].message,
          isRead: true, // Mark as read
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error, maybe revert the UI change
      print(e);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      // Optimistically update the UI
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          message: n.message,
          isRead: true, // Mark all as read
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
