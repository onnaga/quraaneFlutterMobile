import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masjed/models/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class User extends ChangeNotifier {
  // String? baseUrl = "http://192.168.1.5:8000/api/";
// String? baseUrl = "http://127.0.0.1:8000/api/";

  String? baseUrl = dotenv.env['BASE_URL'];
  String? token;
  String? username;
  int? id;
  int? privilege;
  UserToShowProfile? profileUserData;
  List<endedSurah> soarToSend = [];
  List<homeWorkSorah> hSoarToSend = [];
  List<endedSurah> ahadithToSend = [];
  List<homeWorkSorah> hAhadithToSend = [];
  Map<String, dynamic>? details;
  File? image;
  String? image_hash;
  String? teache_name;
  late int daoraId;
  final Dio dio = Dio(BaseOptions(headers: {
    'content-Type': 'application/json',
    'Accept': 'application/json'
  }));
// دالة مساعدة لتحليل أخطاء Dio
  String _handleDioError(DioException e) {
    // إذا كان الخطأ بسبب استجابة من الخادم (مثل 404, 401, 500)
    if (e.response != null && e.response!.data is Map) {
      // حاول قراءة رسالة الخطأ من JSON الذي أرسله الخادم
      return e.response!.data['message'] ?? 'حدث خطأ غير معروف من الخادم.';
    } else {
      // إذا لم تكن هناك استجابة، فهذا يعني غالباً وجود مشكلة في الشبكة
      return 'تعذر الاتصال بالخادم، يرجى التحقق من اتصالك بالإنترنت.';
    }
  }

  Future<bool> login(String username, String password) async {
    make_all_null();
    var url = '${baseUrl}login';
    var formData = FormData.fromMap({
      'name': username,
      'password': password,
    });

    try {
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ نجاح تسجيل الدخول
        token = response.data['token'].toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token as String);

        // تحديث حالة الـ Provider
        id = response.data['id'];
        this.username = response.data['name'];
        privilege = response.data['privilege'];
        teache_name = response.data['teache_name'];

        int daoraIdValue = response.data['daora_id'] ?? 0;

        await prefs.setInt("currentDaoraId", daoraIdValue);
        await prefs.setInt("privilege", privilege!);
        daoraId = daoraIdValue;

        // ⭐====== تعديل مؤكد: قم بتعبئة details map هنا ======⭐
        details = {
          'phone': response.data['phone_number'],
          'age': response.data['age'],
          'job': response.data['job'],
          'address': response.data['address'],
          'family_status': response.data['family_status'],
        };
        // ⭐================= نهاية التعديل =================⭐

        return true;
      } else {
        throw Exception('حدث خطأ غير متوقع.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      // print("Error in login: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      // print("Error in login: $e");
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<bool> register(
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
    make_all_null();
    var url = '${baseUrl}register';

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
      var response = await dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ نجاح التسجيل
        token = response.data['token'].toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token as String);

        id = response.data['id'];
        this.username = response.data['name'];
        privilege = response.data['privilege'];

        // ⭐====== تعديل مؤكد: قم بتعبئة details map هنا ======⭐
        details = {
          'phone': response.data['phone_number'],
          'age': response.data['age'],
          'job': response.data['job'],
          'address': response.data['address'],
          'family_status': response.data['family_status'],
        };
        // ⭐================= نهاية التعديل =================⭐

        return true;
      } else {
        throw Exception('فشل التسجيل لسبب غير معروف.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      // print("Error in register: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      // print("Error in register: $e");
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  /// تقوم بتبديل صلاحية الأستاذ وترجع خريطة بالنتيجة.
  Future<Map<String, dynamic>> toggleTeacherPrivilege(int targetUserId) async {
    // استبدل 'your_api_url' بعنوان الـ API الأساسي الخاص بك
    var apiUrl = '${baseUrl}users/$targetUserId/toggle-privilege';

    try {
      final response = await dio.put(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // تأكد من أن متغير التوكن معرف
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // في حالة النجاح، نرجع حالة النجاح وبيانات المستخدم المحدثة
        return {'success': true, 'user': response.data['user']};
      } else {
        // في حالة فشل غير متوقع من الخادم
        final message = response.data['message'] ?? 'حدث خطأ غير متوقع';
        return {'success': false, 'message': message};
      }
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio (مثل 403, 404, 500)
      final errorMessage = e.response?.data['message'] ?? 'فشل الاتصال بالخادم';
      // print('Error toggling privilege: $errorMessage');
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      // print('An unexpected error occurred: $e');
      return {'success': false, 'message': 'حدث خطأ غير معروف'};
    }
  }

  Future<Map<String, dynamic>> login_via_token() async {
    // print('inside login via token');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString('token');
    // print('Retrieved token: $token');

    if (token == null || token == "null" || token!.isEmpty) {
      throw Exception('Token not found');
    }

    var url = '${baseUrl}get_user_info';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      var response = await dio.post(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ نجاح استرجاع البيانات
        id = response.data['id'];
        username = response.data['name'];
        privilege = response.data['privilege'];
        teache_name = response.data['teache_name'];
        image_hash = response.data['photo_hash'];
        int daoraIdValue = response.data['daora_id'] ?? 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("currentDaoraId", daoraIdValue);
        await prefs.setInt("privilege", privilege!);
        daoraId = daoraIdValue;

        // ⭐====== تعديل مؤكد: قم بتعبئة details map هنا ======⭐
        details = {
          'phone': response.data['phone_number'],
          'age': response.data['age'],
          'job': response.data['job'],
          'address': response.data['address'],
          'family_status': response.data['family_status'],
        };
        // ⭐================= نهاية التعديل =================⭐

        return {'daoraId': daoraIdValue};
      } else {
        throw Exception('فشل استرجاع البيانات.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      // print('Error in login_via_token: $errorMessage');
      if (e.response?.statusCode == 401) {
        // إذا كان التوكين منتهي الصلاحية أو غير صالح
        // يمكنك هنا حذف التوكين القديم وتوجيه المستخدم لصفحة تسجيل الدخول
      }
      throw Exception(errorMessage);
    } catch (e) {
      // print('Error in login_via_token: $e');
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<UserToShowProfile> get_user_info(int userId) async {
    if (token == "null" || token == null) {
      throw Exception('أنت غير مسجل الدخول');
    }

    final url = '${baseUrl}get_user_info'; // تأكد أن هذا الرابط صحيح
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    // إرسال id المستخدم المطلوب في جسم الطلب
    final formData = FormData.fromMap({'id': userId});

    try {
      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserToShowProfile.fromJson(response.data);
      } else {
        throw Exception('فشل في جلب بيانات المستخدم.');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      // print('Error in get_user_info: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      // print('Error in get_user_info: $e');
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

  Future<File?> getImage(String id, imageHashSended) async {
    make_all_null();
    if (imageHashSended != null) {
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      File file = File(
        path.join(
          documentDirectory.path,
          path.basename(imageHashSended!),
        ),
      );
      //image exist inside appData
      if (await file.exists()) {
        image = file;
      }
      //image not exist inside appData
      else {
        // getImage(id);
      }
    } else {
      image = null;
    }

    // print("get image");
    return image;
  }

  Future<bool> resetPassword(
      BuildContext context, String oldPassword, String newPassword) async {
    debugger();
    var url = '${baseUrl}update_password_user';
    var formData = FormData.fromMap({
      'old_password': oldPassword,
      'password': newPassword,
    });
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer $token";
    var response = await dio.post(url, data: formData,
        options: Options(validateStatus: (i) {
      return true;
    }));
    if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      // print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      token = response.data['token'].toString();
      Provider.of<SharedPreferences>(context, listen: false).remove('token');
      Provider.of<SharedPreferences>(context, listen: false)
          .setString('token', token as String);
      // print('Token saved: $token');
      return true;
    }
  }

  Future<bool> update_details(
    int age,
    String phoneNumber,
    String job,
    String address,
    String? familyStatus,
  ) async {
    final url = '${baseUrl}update_details';
    final formData = FormData.fromMap({
      'age': age,
      'phone_number': phoneNumber,
      'job': job,
      'address': address,
      'family_status': familyStatus ?? '',
    });
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        details = {'phone': phoneNumber, 'age': age};
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      throw Exception('فشل تحديث البيانات. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<Map<String, List<String>>> fetchSuggestions() async {
    final url = '${baseUrl}suggestions';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final List<String> jobs = List<String>.from(data['jobs']);
        final List<String> areas = List<String>.from(data['areas']);
        return {'jobs': jobs, 'areas': areas};
      } else {
        // رسالة الخطأ هنا تعني أن اسم المستخدم موجود مسبقاً
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> add_admin(
    String username,
    String password,
    String privilege,
    int? daoraId,
    String job,
    String address,
    String? familyStatus,
  ) async {
    final url = '${baseUrl}add_admin';
    final formData = FormData.fromMap({
      'name': username,
      'password': password,
      'privilege': privilege,
      'daora_id': daoraId ?? 0,
      'job': job,
      'address': address,
      'family_status': familyStatus,
    });
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      final response = await dio.post(url, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('user_added');
        return true;
      } else {
        // هذا الجزء نظرياً لن يتم الوصول إليه لأن Dio سيرمي Exception
        throw Exception('فشل إضافة المستخدم لسبب غير معروف.');
      }
    } on DioException catch (e) {
      // ✅===== هنا التعديل الجوهري =====✅
      // نفحص إذا كان هناك استجابة من الخادم تحتوي على تفاصيل الخطأ
      if (e.response != null && e.response?.data != null) {
        // نستخرج رسالة الخطأ التي أرسلها الباك إند
        final serverMessage =
            e.response?.data['message'] ?? 'حدث خطأ من الخادم.';
        throw Exception(serverMessage);
      } else {
        // في حال وجود خطأ في الشبكة أو مشكلة أخرى
        throw Exception(
            'فشل الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.');
      }
    } catch (e) {
      // للتعامل مع أي أخطاء أخرى غير متوقعة
      // print(e);
      throw Exception('حدث خطأ غير متوقع.');
    }
  }

Future<bool> deleteLatestQuranItem(
    int userId, Map<String, dynamic> itemToDelete) async {
  if (token == null) {
    throw Exception('المستخدم غير مسجل دخوله');
  }

  dio.options.headers["authorization"] = "Bearer $token";
  var url = '${baseUrl}delete_latest_quraan/$userId';
print(jsonEncode(itemToDelete));
print(userId);
  try {
    // أرسل العنصر (كـ Map) مباشرة، وسيقوم dio بتحويله لـ JSON
    // أو استخدم jsonEncode إذا كنت تفضل الإرسال كـ raw string
    var response = await dio.post(url, data: jsonEncode(itemToDelete));

    if (response.statusCode == 200 || response.statusCode == 201 ) {
      // تم الحذف بنجاح
      return true;
    } else {
      // معالجة الحالات غير المتوقعة (مثل 201 أو غيرها)
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    }
  } on DioException catch (e) {
    // معالجة الأخطاء التي يرجعها الخادم (403, 404, 422, 500)
    if (e.response != null && e.response!.data != null) {
      // حاول قراءة رسالة الخطأ المحددة من الـ Backend
      final errorMessage = e.response!.data['message'] ??
          e.response!.data['error'] ??
          'حدث خطأ. يرجى المحاولة لاحقاً.';
      throw Exception(errorMessage);
    } else {
      // خطأ في الاتصال أو خطأ عام من Dio
      throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
    }
  } catch (e) {
    // أي أخطاء أخرى
    throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
  }
}



// ✅
// (الدالة الجديدة للحديث - أضفها)
// ✅
Future<bool> deleteLatestHadithItem(
    int userId, Map<String, dynamic> itemToDelete) async {
  if (token == null) {
    throw Exception('المستخدم غير مسجل دخوله');
  }
  dio.options.headers["authorization"] = "Bearer $token";
  // ✅ !!! تغيير الرابط
  var url = '${baseUrl}delete_latest_hadith/$userId';
  print(jsonEncode(itemToDelete));
  print(userId);
  try {
    var response = await dio.post(url, data: jsonEncode(itemToDelete));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    }
  } on DioException catch (e) {
    if (e.response != null && e.response!.data != null) {
      final errorMessage = e.response!.data['message'] ??
          e.response!.data['error'] ??
          'حدث خطأ. يرجى المحاولة لاحقاً.';
      throw Exception(errorMessage);
    } else {
      throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
    }
  } catch (e) {
    throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
  }
}

// ✅
// (الدالة الجديدة للأنشطة - أضفها)
// ✅
Future<bool> deleteLatestActivityItem(
    int userId, Map<String, dynamic> itemToDelete) async {
  if (token == null) {
    throw Exception('المستخدم غير مسجل دخوله');
  }
  dio.options.headers["authorization"] = "Bearer $token";
  // ✅ !!! تغيير الرابط
  var url = '${baseUrl}delete_latest_activity/$userId';
  print(jsonEncode(itemToDelete));
  print(userId);
  try {
    var response = await dio.post(url, data: jsonEncode(itemToDelete));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    }
  } on DioException catch (e) {
    if (e.response != null && e.response!.data != null) {
      final errorMessage = e.response!.data['message'] ??
          e.response!.data['error'] ??
          'حدث خطأ. يرجى المحاولة لاحقاً.';
      throw Exception(errorMessage);
    } else {
      throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
    }
  } catch (e) {
    throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
  }
}



// ✅
// (الدالة الجديدة للملاحظات - أضفها)
// ✅
Future<bool> deleteLatestNoteItem(int userId) async {
  if (token == null) {
    throw Exception('المستخدم غير مسجل دخوله');
  }
  dio.options.headers["authorization"] = "Bearer $token";
  // ✅ !!! تغيير الرابط (لا نحتاج لإرسال body هنا)
  var url = '${baseUrl}delete_latest_note/$userId'; 
  print(userId);
  try {
    // ✅ نستخدم 'post' كما طلبت (للتوحيد مع البقية)
    var response = await dio.post(url); 
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'حدث خطأ غير معروف');
    }
  } on DioException catch (e) {
    if (e.response != null && e.response!.data != null) {
      final errorMessage = e.response!.data['message'] ??
          e.response!.data['error'] ??
          'حدث خطأ. يرجى المحاولة لاحقاً.';
      throw Exception(errorMessage);
    } else {
      throw Exception('فشلت عملية الحذف. يرجى التحقق من اتصالك بالإنترنت.');
    }
  } catch (e) {
    throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
  }
}

  Future<bool> add_latest_quraan_hadith(
      int userId, List<dynamic> dataToSend, bool quran) async {
    dio.options.headers["authorization"] = "Bearer $token";
    var url = quran
        ? '${baseUrl}add_latest_quraan/$userId'
        : '${baseUrl}add_latest_hadith/$userId';
print(jsonEncode(dataToSend));
    try {
      print(dataToSend);
      var response = await dio.post(url, data: jsonEncode(dataToSend));
      // print('response is : $response');
      // print('status code is :${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      if (response.statusCode == 500) {
        // print('response is : $response');
        throw Exception(response.data ?? 'حدث خطأ في الخادم');
      } else {
        throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      throw Exception('فشلت عملية الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> add_latest_activity(int userId, List<dynamic> dataToSend) async {
    dio.options.headers["authorization"] = "Bearer $token";
    final url = '${baseUrl}add_latest_activity/$userId';
print("$dataToSend");
    try {
      final response = await dio.post(url, data: jsonEncode(dataToSend));
      // print('response is $response');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('user_added');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      throw Exception('فشلت الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> add_latest_notes(
      int userId, String note, String lostPoint) async {
    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}add_latest_note/$userId';
    var formData = FormData.fromMap({'lost_point': lostPoint, 'note': note});

    try {
      var response = await dio.post(url, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('user_added');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'حدث خطأ في الخادم');
      }
    } catch (e) {
      throw Exception('فشلت عملية الإضافة. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> Delete_user(BuildContext context, userId) async {
    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}users';

    var response = await dio.delete(
      url,
      data: {
        'user_id': userId, // 🔑 أرسل user_id هنا
      },
      options: Options(validateStatus: (i) => true),
    );

    if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('توجد مشكلة في الخادم'),
        backgroundColor: Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message'] ?? 'خطأ'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }

    // print('user_deleted');
    return true;
  }

// لا تحتاج هذه الدالة إلى context الآن
  Future<Map<String, dynamic>> leave_student(userId) async {
    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}leave_student?user_id=$userId';

    try {
      var response =
          await dio.get(url, options: Options(validateStatus: (status) {
        // السماح لـ Dio بمعالجة الأكواد 2xx كنجاح والباقي كخطأ
        return status != null && status < 500;
      }));

      // في حال كان الرد ناجحًا (مثل 200 OK)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('user_leaved');
        // أرجع نتيجة النجاح مع رسالة
        return {'success': true, 'message': 'تم إخراج الطالب بنجاح'};
      } else {
        // إذا كان الرد خطأ (مثل 401 أو 404)، أرجع رسالة الخطأ من الخادم
        return {
          'success': false,
          'message': response.data['message'] ?? 'حدث خطأ غير متوقع'
        };
      }
    } catch (e) {
      // في حال وجود مشكلة بالشبكة أو بالخادم (مثل 500)
      // print(e.toString());
      return {'success': false, 'message': 'توجد مشكلة في الاتصال بالخادم'};
    }
  }

  void update_image(File image) {
    this.image = image;
    notifyListeners();
  }

  void make_all_null() {
    details = null;
    image = null;
    username = null;
    teache_name = null;
    image_hash = null;
    privilege = null;
    token = null;
  }
}
