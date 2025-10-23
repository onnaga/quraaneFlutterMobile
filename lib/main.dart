
import 'package:flutter/material.dart';
import 'package:masjed/state/offline.dart';
import 'package:masjed/state/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjed/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- 1. قم بالاستيراد
// ✅ الخطوة 1: تعريف دالة الخلفية (يجب أن تكون خارج أي كلاس)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // print("🚀 Background task started: $task");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        // print("❌ Background task failed: No auth token found.");
        return false;
      }

      final userProvider = User();
      userProvider.token = token;
      final offlineService = OfflineSyncService();

      // ✅ جعل كل عملية مزامنة مستقلة لزيادة الموثوقية
      try {
        // print("Syncing Quran...");
        await offlineService.sendPendingQuranSubmissions(userProvider);
      } catch (e) {
        // print("❗️ Error syncing Quran: $e");
      }
      
      try {
        // print("Syncing Hadith...");
        await offlineService.sendPendingHadithSubmissions(userProvider);
      } catch (e) {
        // print("❗️ Error syncing Hadith: $e");
      }

      try {
        // print("Syncing Activities...");
        await offlineService.sendPendingActivitySubmissions(userProvider);
      } catch (e) {
        // print("❗️ Error syncing Activities: $e");
      }
      
      try {
        // print("Syncing Notes...");
        await offlineService.sendPendingNotesSubmissions(userProvider);
      } catch (e) {
        // print("❗️ Error syncing Notes: $e");
      }

      // print("✅ Background task finished all attempts.");
      return true; // نرجع true دائمًا لأن المهمة نفذت محاولاتها

    } catch (e) {
      // print("❌ A critical error occurred in background task setup: $e");
      return false; // فشل حرج في الإعداد
    }
  });
}

// دالة معالجة إشعارات Firebase في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("إشعار في الخلفية: ${message.messageId}");
}

void main() async {
  // تأكد من تهيئة Flutter Binding أولاً

  
  // قم بتحميل المتغيرات من ملف .env
  await dotenv.load(fileName: ".env");
  // تهيئة Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ الخطوة 4: تهيئة WorkManager قبل تشغيل التطبيق
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // اجعلها false عند إطلاق النسخة النهائية
  );

  // الكود الأصلي الخاص بك
  runApp(MyApp(await SharedPreferences.getInstance()));
}


