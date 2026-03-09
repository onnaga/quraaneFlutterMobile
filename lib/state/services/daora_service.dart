import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_client.dart';

class DaoraService {
  final Dio _dio = ApiClient().dio;
  final String _baseUrl = ApiClient().baseUrl;

  Future<String?> fetchDaoraPhoto(int daoraId) async {
    final url = '${_baseUrl}daoras/photos';
    try {
      final response = await _dio.post(
        url,
        data: {
          "ids": [daoraId]
        },
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final raw =
            response.data is String ? jsonDecode(response.data) : response.data;
        return raw["photos"]["$daoraId"];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getAllDaoras() async {
    final url = '${_baseUrl}get_all_daoras';
    try {
      final response = await _dio.get(
        url,
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is String ? jsonDecode(raw) : raw;
        return (data['daoras'] as List?) ?? [];
      } else {
        throw Exception("خطأ من السيرفر: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("فشل جلب الدورات: ${e.toString()}");
    }
  }

  Future<String> deleteDaora(int id, String? token) async {
    if (token == null || token.isEmpty) {
      return "يرجى تسجيل الدخول أولاً";
    }
    try {
      final response = await _dio.delete(
        "${_baseUrl}delete_daora/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        return response.data["message"] ?? "تم حذف الدورة";
      } else {
        return response.data["message"] ?? "فشل الحذف";
      }
    } catch (e) {
      return "حدث خطأ أثناء الحذف: $e";
    }
  }

  Future<String> addDaora(
    String daoraName,
    String adminName,
    String password,
    File? photo,
    String? token,
  ) async {
    if (token == null || token.isEmpty) {
      return "يرجى تسجيل الدخول أولاً للإضافة";
    }
    try {
      FormData formData = FormData.fromMap({
        "daora_name": daoraName,
        "name": adminName,
        "password": password,
        if (photo != null)
          "photo": await MultipartFile.fromFile(photo.path,
              filename: photo.path.split("/").last),
      });

      final response = await _dio.post(
        "${_baseUrl}add_daora",
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
    final url = '${_baseUrl}change_my_daora';
    try {
      final response = await _dio.post(
        url,
        data: {
          "user_id": userId,
          "new_daora_id": newDaoraId,
        },
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final msg = response.data["message"] ?? "تم تغيير الدورة بنجاح 🎉";
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
  }

  Future<Map<String, List<dynamic>>> getJobsAndAreas(String? token) async {
    if (token == null || token.isEmpty) {
      throw Exception('يرجى تسجيل الدخول أولاً');
    }
    try {
      final response = await _dio.get(
        '${_baseUrl}jobs-and-areas',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> jobsJson = response.data['data']['jobs'];
        final List<dynamic> areasJson = response.data['data']['areas'];

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
