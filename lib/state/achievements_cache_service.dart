
import 'dart:convert';
import 'dart:io';

import 'package:masjed/models/objects.dart'; // تأكد من أن reciveLatest معرف هنا
import 'package:path_provider/path_provider.dart';

class AchievementsCacheService {
  // دالة لتحديد مسار ملف التخزين
  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/achievements_cache.json');
  }

  /// يقرأ كل البيانات المخزنة من الملف
  Future<Map<String, dynamic>> _readCache() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          return jsonDecode(contents);
        }
      }
    } catch (e) {
      // print("Error reading achievements cache: $e");
    }
    return {}; // أرجع خريطة فارغة في حالة عدم وجود ملف أو حدوث خطأ
  }

  /// يحفظ بيانات إنجازات جميع الطلاب في ملف واحد
  Future<void> saveAllAchievements(Map<int, reciveLatest> allData) async {
    try {
      final file = await _getCacheFile();
      // تحويل الخريطة إلى صيغة قابلة للتخزين (مفتاح String)
      final Map<String, dynamic> jsonMap = allData.map(
        (userId, data) => MapEntry(userId.toString(), data.toJson()),
      );
      await file.writeAsString(jsonEncode(jsonMap));
      // print("✅ All student achievements saved to cache.");
    } catch (e) {
      // print("❌ Failed to save achievements to cache: $e");
    }
  }

  /// يجلب بيانات إنجازات طالب معين من الملف المحفوظ
  Future<reciveLatest?> getAchievementsForUser(int userId) async {
    try {
      final cache = await _readCache();
      final userKey = userId.toString();
      if (cache.containsKey(userKey)) {
        // print("Found achievements for user $userId in cache.");
        return reciveLatest.fromJson(cache[userKey]);
      }
    } catch (e) {
      // print("Error getting achievements for user $userId from cache: $e");
    }
    // print("No achievements found for user $userId in cache.");
    return null; // أرجع null إذا لم يتم العثور على بيانات للطالب
  }
}