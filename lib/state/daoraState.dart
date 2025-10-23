import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- 1. قم بالاستيراد

class Daorastate extends ChangeNotifier {
// String? baseUrl = "http://192.168.1.5:8000/api/";
// String? baseUrl = "http://127.0.0.1:8000/api/";

  String? baseUrl = dotenv.env['BASE_URL'];
  final Dio dio = Dio(BaseOptions(
    headers: {
      'content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // 🆕 الدورة الحالية
  int? _currentDaoraId;

  int? get currentDaoraId => _currentDaoraId;

  Future<void> loadDaoraId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDaoraId = prefs.getInt("currentDaoraId");
    notifyListeners();
  }

  Future<void> setDaoraId(int id) async {
    _currentDaoraId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("currentDaoraId", id);
    notifyListeners();
  }

  // 📸 كاش صور
  final int _cacheLimit = 20; // الحد الأقصى لعدد الصور

  /// كاش للصور
  final Map<int, String?> _photosCache = {};

  Future<String?> getDaoraPhotos(int daoraId) async {
    if (_photosCache.containsKey(daoraId)) {
      // print("♻️ رجعت صورة الدورة $daoraId من الكاش");
      return _photosCache[daoraId];
    }

    final url = '${baseUrl}daoras/photos';
    // print("➡️ جاري طلب صورة الدورة $daoraId من السيرفر");

    try {
      final response = await dio.post(
        url,
        data: {
          "ids": [daoraId]
        },
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final raw =
            response.data is String ? jsonDecode(response.data) : response.data;
        final photoBase64 = raw["photos"]["$daoraId"];

        // 🧹 تحقق من الحد
        if (_photosCache.length >= _cacheLimit) {
          final firstKey = _photosCache.keys.first;
          _photosCache.remove(firstKey);
          // print("🗑️ حذفنا أقدم صورة (id=$firstKey) من الكاش");
        }

        _photosCache[daoraId] = photoBase64;
        if (photoBase64 != null) {
          // print("✅ استلمت صورة الدورة $daoraId وحفظتها بالكاش");
        } else {
          // print("⚠️ الدورة $daoraId بدون صورة");
        }

        return photoBase64;
      } else {
        // print("❌ خطأ عند جلب صورة الدورة $daoraId: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("🔥 استثناء عند جلب صورة الدورة $daoraId: $e");
      return null;
    }
  }

  void clearPhotosCache() {
    // print("🧹 تم مسح كاش الصور كلياً");
    _photosCache.clear();
  }

  Future<List<dynamic>> getAllDaoras() async {
    final url = '${baseUrl}get_all_daoras';
    try {
      final response = await dio.get(
        url,
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;
        return (data['daoras'] as List?) ?? [];
      } else {
        // بدلاً من عرض SnackBar، نرمي خطأ بالرسالة المناسبة
        throw Exception("خطأ من السيرفر: ${response.statusCode}");
      }
    } catch (e) {
      // نرمي خطأ بمعلومات أكثر تفصيلاً
      throw Exception("فشل جلب الدورات: ${e.toString()}");
    }
  }

  Future<String> deleteDaora(int id, token) async {
    try {
      // print('inside delete daora function ');
      // print('token :$token');
      final response = await dio.delete(
        "${baseUrl}delete_daora/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      // print('response : $response ');
      if (response.statusCode == 200) {
        return response.data["message"] ?? "تم حذف الدورة";
      } else {
        return response.data["message"] ?? "فشل الحذف";
      }
    } catch (e) {
      // print('e : $e');
      return "حدث خطأ أثناء الحذف: $e";
    }
  }

  Future<String> addDaora(
    String daoraName,
    String adminName,
    String password,
    File? photo,
    String token,
    
  ) async {
    try {
      FormData formData = FormData.fromMap({
        "daora_name": daoraName,
        "name": adminName,
        "password": password,
        if (photo != null)
          "photo": await MultipartFile.fromFile(photo.path,
              filename: photo.path.split("/").last),
      });

      final response = await dio.post(
        "${baseUrl}add_daora",
        data: formData,
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return response.data["message"] ?? "تم إنشاء الدورة بنجاح";
      } else {
        return response.data["message"] ?? "فشل إنشاء الدورة";
      }
    } catch (e) {
      return "خطأ أثناء إنشاء الدورة: $e";
    }
  }
Future<Map<String, dynamic>> changeMyDaora(int userId, int newDaoraId) async {
  final url = '${baseUrl}change_my_daora';

  try {
    final response = await dio.post(
      url,
      data: {
        "user_id": userId,
        "new_daora_id": newDaoraId,
      },
      options: Options(validateStatus: (_) => true),
    );

    if (response.statusCode == 200) {
      final msg = response.data["message"] ?? "تم تغيير الدورة بنجاح 🎉";
      // 📝 خزن الدورة الجديدة محلياً
      await setDaoraId(newDaoraId);
      return {'success': true, 'message': msg};
    } else {
      final msg = response.data["messages"] ??
          response.data["message"] ??
          "فشل تغيير الدورة";
      return {'success': false, 'message': msg};
    }
  } catch (e) {
    final errMsg = "خطأ أثناء تغيير الدورة: $e";
    return {'success': false, 'message': errMsg};
  }
}  // ... (داخل كلاس User)

  // ✅ تابع جديد لجلب الأعمال والمناطق
  Future<Map<String, List<dynamic>>> getJobsAndAreas(token) async {
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      final response = await dio.get('${baseUrl}jobs-and-areas');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // ✅ التحليل والتحويل إلى قوائم منظمة
        final List<dynamic> jobsJson = response.data['data']['jobs'];
        final List<dynamic> areasJson = response.data['data']['areas'];

        // يمكنك إنشاء مودلز Dart خاصة بـ Job و Area لتحويل البيانات إليها
        // لكن للتبسيط، سنرجعها كقائمة من الخرائط مباشرة
        return {
          'jobs': jobsJson,
          'areas': areasJson,
        };
      } else {
        throw Exception('فشل جلب البيانات من الخادم');
      }
    } catch (e) {
      throw Exception('حدث خطأ في الشبكة، يرجى المحاولة مرة أخرى.');
    }
  }
}
