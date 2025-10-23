import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String footer; // ✅ إضافة حقل الفوتر
  final DateTime createdAt;
  DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.footer, // ✅ إضافته للـ constructor
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    dynamic data = json['data'];

    if (data is String) {
      data = jsonDecode(data);
    }

    return NotificationModel(
      id: json['id'].toString(),
      title: data['title'] ?? 'إشعار جديد',
      body: data['body'] ?? 'لديك رسالة جديدة.',
      footer: data['footer'] ?? '', // ✅ قراءة الفوتر من البيانات
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  bool get isUnread => readAt == null;
}