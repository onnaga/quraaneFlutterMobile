import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:masjed/models/objects.dart';
import 'api_client.dart';

class UserService {
  final Dio _dio = ApiClient().dio;
  final String _baseUrl = ApiClient().baseUrl;

  String _handleDioError(DioException e) {
    if (e.response != null && e.response!.data is Map) {
      return e.response!.data['message'] ?? 'حدث خطأ غير معروف من الخادم.';
    } else {
      return 'تعذر الاتصال بالخادم، يرجى التحقق من اتصالك بالإنترنت.';
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    var url = '${_baseUrl}login';
    var formData = FormData.fromMap({
      'name': username,
      'password': password,
    });

    try {
      var response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        throw Exception('حدث خطأ غير متوقع.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String phone,
    int age,
    List<int> chapters,
    int daoraId,
    String job,
    String address,
    String? familyStatus,
  ) async {
    var url = '${_baseUrl}register';
    var formData = FormData.fromMap({
      'name': username,
      'password': password,
      'phone_number': phone,
      'age': age.toString(),
      'job': job,
      'address': address,
      'family_status': familyStatus ?? '',
      'ended_quraan_in_aukaf': chapters.toString(),
      'daora_id': daoraId,
    });

    try {
      var response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        throw Exception('فشل التسجيل لسبب غير معروف.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<Map<String, dynamic>> toggleTeacherPrivilege(
      int targetUserId, String token) async {
    var apiUrl = '${_baseUrl}users/$targetUserId/toggle-privilege';

    try {
      final response = await _dio.put(
        apiUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data['user']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'حدث خطأ غير متوقع'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'فشل الاتصال بالخادم'
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ غير معروف'};
    }
  }

  Future<Map<String, dynamic>> loginViaToken(String token) async {
    var url = '${_baseUrl}get_user_info';
    try {
      var response = await _dio.post(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        throw Exception('فشل استرجاع البيانات.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<UserToShowProfile> getUserInfo(int userId, String token) async {
    final url = '${_baseUrl}get_user_info';
    final formData = FormData.fromMap({'id': userId});

    try {
      final response = await _dio.post(url,
          data: formData,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserToShowProfile.fromJson(response.data);
      } else {
        throw Exception('فشل في جلب بيانات المستخدم.');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String oldPassword, String newPassword, String token) async {
    var url = '${_baseUrl}update_password_user';
    var formData = FormData.fromMap(
        {'old_password': oldPassword, 'password': newPassword});

    var response = await _dio.post(url,
        data: formData,
        options: Options(
            headers: {"authorization": "Bearer $token"},
            validateStatus: (i) => true));

    if (response.statusCode == 500) {
      return {'success': false, 'message': 'مشكلة في الخادم'};
    }
    if (response.statusCode == 401) {
      return {
        'success': false,
        'message': response.data['message'] ?? 'غير مصرح'
      };
    }

    return {'success': true, 'token': response.data['token'].toString()};
  }

  Future<Map<String, dynamic>> updateDetails(int age, String phoneNumber,
      String job, String address, String? familyStatus, String token) async {
    final url = '${_baseUrl}update_details';
    final formData = FormData.fromMap({
      'age': age,
      'phone_number': phoneNumber,
      'job': job,
      'address': address,
      'family_status': familyStatus ?? '',
    });

    try {
      final response = await _dio.post(url,
          data: formData,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      throw Exception('فشل تحديث البيانات. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<Map<String, List<String>>> fetchSuggestions() async {
    final url = '${_baseUrl}suggestions';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return {
          'jobs': List<String>.from(data['jobs']),
          'areas': List<String>.from(data['areas'])
        };
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> addAdmin(
      String username,
      String password,
      String privilege,
      int? daoraId,
      String job,
      String address,
      String? familyStatus,
      String token) async {
    final url = '${_baseUrl}add_admin';
    final formData = FormData.fromMap({
      'name': username,
      'password': password,
      'privilege': privilege,
      'daora_id': daoraId ?? 0,
      'job': job,
      'address': address,
      'family_status': familyStatus,
    });

    try {
      final response = await _dio.post(url,
          data: formData,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception('فشل إضافة المستخدم لسبب غير معروف.');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ من الخادم.');
      } else {
        throw Exception(
            'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<bool> deleteLatestItem(int userId, Map<String, dynamic> itemToDelete,
      String type, String token) async {
    var url = '${_baseUrl}delete_latest_$type/$userId';
    try {
      var response = await _dio.post(url,
          data: jsonEncode(itemToDelete),
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ??
            e.response!.data['error'] ??
            'حدث خطأ. يرجى المحاولة لاحقاً.');
      } else {
        throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  Future<bool> deleteLatestNoteItem(int userId, String token) async {
    var url = '${_baseUrl}delete_latest_note/$userId';
    try {
      var response = await _dio.post(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ??
            e.response!.data['error'] ??
            'حدث خطأ. يرجى المحاولة لاحقاً.');
      } else {
        throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  Future<bool> addLatestQuranHadith(
      int userId, List<dynamic> dataToSend, bool quran, String token) async {
    var url = quran
        ? '${_baseUrl}add_latest_quraan/$userId'
        : '${_baseUrl}add_latest_hadith/$userId';
    try {
      var response = await _dio.post(url,
          data: jsonEncode(dataToSend),
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      if (response.statusCode == 500)
        throw Exception(response.data ?? 'حدث خطأ في الخادم');
      throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
    } catch (e) {
      throw Exception('فشلت عملية الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> addLatestActivity(
      int userId, List<dynamic> dataToSend, String token) async {
    final url = '${_baseUrl}add_latest_activity/$userId';
    try {
      final response = await _dio.post(url,
          data: jsonEncode(dataToSend),
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
    } catch (e) {
      throw Exception('فشلت الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> addLatestNotes(
      int userId, String note, String lostPoint, String token) async {
    var url = '${_baseUrl}add_latest_note/$userId';
    var formData = FormData.fromMap({'lost_point': lostPoint, 'note': note});

    try {
      var response = await _dio.post(url,
          data: formData,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
    } catch (e) {
      throw Exception('فشلت عملية الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId, String token) async {
    var url = '${_baseUrl}users';

    var response = await _dio.delete(
      url,
      data: {'user_id': userId},
      options: Options(
          headers: {"authorization": "Bearer $token"},
          validateStatus: (i) => true),
    );

    if (response.statusCode == 500)
      return {'success': false, 'message': 'توجد مشكلة في الخادم'};
    if (response.statusCode == 401 || response.statusCode == 403)
      return {'success': false, 'message': response.data['message'] ?? 'خطأ'};

    return {'success': true};
  }

  Future<Map<String, dynamic>> leaveStudent(int userId, String token) async {
    var url = '${_baseUrl}leave_student?user_id=$userId';

    try {
      var response = await _dio.get(url,
          options: Options(
              headers: {"authorization": "Bearer $token"},
              validateStatus: (status) => status != null && status < 500));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم إخراج الطالب بنجاح'};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'حدث خطأ غير متوقع'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'توجد مشكلة في الاتصال بالخادم'};
    }
  }
}
