import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masjed/models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BASE_URL']! ,// 👈 غيّر هذا حسب سيرفرك
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  /// ✅ مسح كل الإشعارات (نستعملها عند تسجيل الخروج)
  void clear() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Fetch notifications from Laravel API
  Future<void> fetchNotifications(String userAuthToken) async {
    // ✅ تأجيل التحديث الأول بعد بناء الواجهة
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _dio.get(
        'notifications',
        options: Options(
          headers: {'Authorization': 'Bearer $userAuthToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        _notifications = responseData
            .map((data) => NotificationModel.fromJson(data))
            .toList();
      } else {
        // print('❌ Failed to fetch notifications. Status: ${response.statusCode}');
        _notifications = [];
      }
    } catch (e) {
      // print('❌ Error fetching notifications: $e');
      _notifications = [];
    }

    _isLoading = false;
    notifyListeners(); // ✅ هذا بعد انتهاء العملية، آمن
  }

  /// ✅ Add a new notification (e.g. from FCM foreground)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// ✅ Mark all notifications as read
  Future<void> markAllAsRead(String userAuthToken) async {
    bool hadUnread = unreadCount > 0;
    if (hadUnread) {
      for (var notification in _notifications) {
        if (notification.isUnread) {
          notification.readAt = DateTime.now();
        }
      }
      notifyListeners();
    }

    try {
      await _dio.post(
        'notifications/mark-as-read',
        options: Options(
          headers: {'Authorization': 'Bearer $userAuthToken'},
        ),
      );
      // print('✅ Marked all notifications as read on server.');
    } catch (e) {
      // print('❌ Error marking notifications as read on server: $e');
    }
  }
}
