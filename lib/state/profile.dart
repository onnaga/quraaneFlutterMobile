import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masjed/models/objects.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ChangeNotifier {
// String? baseUrl = "http://192.168.1.5:8000/api/";
// String? baseUrl = "http://127.0.0.1:8000/api/";

    String? baseUrl = dotenv.env['BASE_URL'];

  int q_points = 0;
  int h_points = 0;
  int a_points = 0;
  int l_points = 0;
  int missing_days = 0;
  int total_points = 0;
  reciveLatest? recivelatest;
  List<dynamic>? ReportsList;
  List<dynamic>? StudetntsWithoutTeachers;
  List<dynamic>? TeachersList;
  List<OneUserRank>? RankUsers;
  List<TestData>? TestsList;
  List<TestUserAccepters> TestUseraccepters = [];
  List<TestUserAccepters> success_users = [];
  List<TestUserAccepters> fail_users = [];
  List<dynamic>? ended_parts;
  List<User_Notification>? notifications;

  final Dio dio = Dio(BaseOptions(headers: {
    'content-Type': 'application/json',
    'Accept': 'application/json'
  }));

  void resetDataForUserReport() {
    q_points = 0;
    h_points = 0;
    a_points = 0;
    l_points = 0;
    total_points = 0;
    missing_days = 0;
    ended_parts = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>> get_score(int privilege, int userId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('token');

      if (token == null || token == "null") {
        // ✅ إرجاع خطأ بدلاً من التعامل مع الواجهة
        return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
      }

      dio.options.headers["authorization"] = "Bearer $token";

      final url = '${baseUrl}get_score';
      final formData = (privilege == 2 || privilege == 3 || privilege == 4)
          ? FormData.fromMap({'id': userId})
          : null;

      final response = await dio.post(
        url,
        data: formData,
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 500) {
        // ✅ إرجاع رسالة الخطأ
        return {'success': false, 'message': 'مشكلة في الخادم'};
      }

      if (response.statusCode == 401) {
        final msg = response.data['message']?.toString() ?? "غير مصرح";
        // ✅ إرجاع رسالة الخطأ
        return {'success': false, 'message': msg};
      }

      // --- منطق النجاح ---
      final points = response.data['points'];
      int parseInt(dynamic val) => int.tryParse(val?.toString() ?? '') ?? 0;

      q_points = parseInt(points?['q_points']);
      h_points = parseInt(points?['h_points']);
      a_points = parseInt(points?['a_points']);
      l_points = parseInt(points?['l_points']);

      total_points = q_points + h_points + a_points - l_points;
      missing_days = parseInt(response.data['missing_days']);
      ended_parts = jsonDecode(
        response.data['ended_quraan_in_aukaf'] ?? "[]",
      );

      // print("get score: total=$total_points, missing=$missing_days");
      // ✅ إرجاع نتيجة النجاح
      return {'success': true, 'message': 'تمت عملية جلب البيانات'};
    } catch (e, st) {
      debugPrint("Error in get_score: $e\n$st");
      // ✅ إرجاع خطأ عام
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }
// ✅ النسخة المُحسّنة: تُرجع الكائن مباشرة أو null عند الفشل
Future<reciveLatest?> get_Latest(int privilege, int userId) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      throw Exception('المستخدم غير مسجل دخوله');
    }

    dio.options.headers["authorization"] = "Bearer $token";

    String url = (privilege == 2 || privilege == 3)
        ? '${baseUrl}get_latest_for_student?user_id=$userId'
        : '${baseUrl}get_latest_for_student';

    var response = await dio.get(url);

    if (response.statusCode == 200) {
      // ✅ أولاً: تأكد أن البيانات مفكوكة JSON
      dynamic data = response.data;

      // أحياناً الخادم يرجعها كنص JSON وليس كـ List
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data == null || data.isEmpty) {
        return null;
      }

      // ✅ الآن أنشئ الكائن بشكل صحيح
      recivelatest = reciveLatest.fromJson(data[0]);
      return recivelatest;
    } else {
      throw Exception('فشل في جلب البيانات من الخادم');
    }
  } catch (e) {
    debugPrint("Error in get_Latest: $e");
    return null;
  }
}

// ✅ تم تمرير daoraId كمتغير بدلاً من استدعاء Provider هنا
  Future<Map<String, dynamic>> get_rank(bool global, int daoraId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == "null" || token == null) {
        return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
      }

      dio.options.headers["authorization"] = "Bearer $token";

      var url =
          global ? '${baseUrl}get_rank_masjed' : '${baseUrl}get_rank_my_group';

      var response = await dio.get(
        url,
        queryParameters: global ? {'daora_id': daoraId} : null,
        options: Options(validateStatus: (i) => true),
      );

      if (response.statusCode == 500) {
        // print(response);
        return {'success': false, 'message': 'مشكلة في الخادم'};
      }

      if (response.statusCode == 401) {
        return {'success': false, 'message': response.data['message']};
      }

      // --- منطق النجاح ---
      RankUsers = [];
      response.data.forEach((item) {
        RankUsers!.add(OneUserRank.fromJson(item));
      });
      RankUsers!.sort((a, b) => b.points.compareTo(a.points));

      // print("get Rank");
      return {'success': true};
    } catch (e, st) {
      debugPrint("Error in get_rank: $e\n$st");
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  Future<bool> add_wanting_students(List<int> watingStudents) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      // رمي خطأ يفيد بأن المستخدم غير مسجل
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}add_wanting_students';

    try {
      var response = await dio.post(url, data: jsonEncode(watingStudents));

      // التعامل مع الأخطاء بناءً على حالة الرد
      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشلت العملية، رمز الخطأ: ${response.statusCode}');
      }

      // print("add wanting students");
      return true;
    } catch (e) {
      // التقاط الأخطاء العامة (مثل مشاكل الشبكة) وإعادة رميها
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<List<TestData>> get_tests(int daoraId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}show_tests?daora_id=$daoraId';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // معالجة البيانات وإرجاعها
      List<TestData> testsList = [];
      response.data['tests'].forEach((item) {
        testsList.add(TestData.fromJson(item));
      });

      List registered = response.data['registered_tests'];
      await preferences.setStringList(
        "registered_tests",
        registered.map((e) => e.toString()).toList(),
      );

      // تحديث القائمة في الـ Provider
      TestsList = testsList;

      return testsList;
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<List<TestUserAccepters>> show_test_accepters(int testId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}show_test_accepters/$testId';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      List<TestUserAccepters> userAccepters = [];
      response.data.forEach((item) {
        userAccepters.add(TestUserAccepters.fromJson(item));
      });

      // تحديث القائمة في الـ Provider
      TestUseraccepters = userAccepters;

      return userAccepters;
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<bool> update_test_accepter_data(
      BuildContext context,
      int testId,
      int userId,
      List<int> thePartToTestIn,
      String rating,
      String notes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null") {
      return false;
    }

    var url = '${baseUrl}update_test_accepter_data/$testId/$userId';
    var formData = FormData.fromMap({
      'the_part_to_test_in': thePartToTestIn.toString(),
      'rating': rating.toString(),
      'notes': notes,
    });
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
    }
    try {
      if (response.data.substring(0, 30) ==
          'SQLSTATE[22007]: Invalid datetime format: 1366 Incorrect integer value: '
              .substring(0, 30)) {
        // print(response.data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("أدخل رقما من 1 إلى 100 في خانة التقييم"),
          backgroundColor: Color.fromARGB(255, 175, 79, 76),
        ));
        return false;
      }
    } catch (e) {
      //if response data is not string it will throw exception there we catch it

      // print(response.data);
    }

    // print("update data to Accepter test");

    return true;
  }

  Future<bool> update_aukaf_tests_after_the_test(
    int testId,
    int userId,
    List<int> thePartToTestIn,
    String rating,
    String notes,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    var url = '${baseUrl}update_aukaf_tests_after_the_test/$testId/$userId';

    try {
      var response = await dio.post(
        url,
        data: {
          'the_part_to_test_in': thePartToTestIn,
          'rating': rating,
          'notes': notes,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );

      if (response.statusCode == 500) {
        // تحقق من الخطأ المحدد
        if (response.data is String &&
            response.data.toString().contains('SQLSTATE[22007]')) {
          throw Exception("أدخل التاريخ بصيغة صحيحة.");
        }
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print("✅ update data to Aukaf test done");
      return response.statusCode == 200 && response.data['status'] == 'success';
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<Map<String, List<TestUserAccepters>>> show_success_students_in_test(
      int testId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}show_success_students_in_test/$testId';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // معالجة البيانات وإرجاعها
      List<TestUserAccepters> successUsers = [];
      List<TestUserAccepters> failUsers = [];

      response.data['success_users'].forEach((item) {
        successUsers.add(TestUserAccepters.fromJson(item));
      });

      response.data['fail_users'].forEach((item) {
        failUsers.add(TestUserAccepters.fromJson(item));
      });

      // تحديث الحالة الداخلية للـ Provider
      success_users = successUsers;
      fail_users = failUsers;

      // print("get Success/fail users");

      return {
        'success_users': successUsers,
        'fail_users': failUsers,
      };
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> take_student(int userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}take_student?user_id=$userId';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print("Student taken successfully");
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> delete_test(int testId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}delete_test/$testId';

    try {
      var response = await dio.delete(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print("delete test");
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }
Future<bool> add_new_test(String at, String notes, bool isAukaf, int daoraId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null || token == "null") {
    throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
  }

  final url = '${baseUrl}add_new_test';
  final formData = FormData.fromMap({
    'End_time': at,
    'notes': notes,
    'aukaf': isAukaf ? 1 : 0,
    'daora_id': daoraId,
  });

  try {
    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        // ✅ السماح لـ dio باستقبال كل رموز الحالة دون رمي خطأ تلقائي
        validateStatus: (status) {
          return status != null && status < 500; // اعتبر أي شيء تحت 500 قابلاً للمعالجة
        },
      ),
    );

    // print("Response from addNewTest: ${response.statusCode} -> ${response.data}");

    // ✅ التعامل مع كل حالة على حدة
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // نجاح
    } else {
      // إذا لم يكن نجاحاً، ارمِ الرسالة القادمة من الـ Backend مباشرة
      throw Exception(response.data['message'] ?? 'حدثت مشكلة غير معروفة');
    }
  } on DioException catch (e) {
    // ✅ معالجة أخطاء dio (مثل انقطاع الإنترنت أو خطأ 500 من الخادم)
    if (e.response != null) {
      // إذا كان هناك استجابة من الخادم ولكن برمز خطأ (500)
      throw Exception(e.response!.data['message'] ?? 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
    } else {
      // إذا لم يكن هناك استجابة (مشكلة شبكة)
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  } catch (e) {
    // معالجة أي أخطاء أخرى غير متوقعة
    throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
  }
}  Future<bool> make_aukaf_test_for_success_students(
      int testId, String at, String notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    final url = '${baseUrl}make_aukaf_test_for_success_students/$testId';
    final formData = FormData.fromMap({
      'End_time': at,
      'notes': notes,
    });

    try {
      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // print("response makeAukafTest: ${response.data}");

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> accept_test(int testId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}accept_test/$testId';

    try {
      var response = await dio.get(url);
      // print('response $response');

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print("accept test");
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> delete_accepted_test(int testId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}delete_accepted_test/$testId';

    try {
      var response = await dio.delete(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print("delete_accepted_test");
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<List<dynamic>> show_reports() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}show_reports';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      // print('response is $response');
      ReportsList = response.data; // تحديث الحالة الداخلية
      return response.data; // إرجاع البيانات
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<List<Map<String, dynamic>>> show_users_without_teacher(
      int daoraId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    // print('token is: $token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    try {
      var url = '${baseUrl}show_users_without_teacher';
      var response = await dio.get(
        url,
        queryParameters: {"daora_id": daoraId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> students = (response.data as List)
            .map((s) => {
                  'user_id': s['user_id'],
                  'ended_quraan_in_aukaf': s['ended_quraan_in_aukaf'],
                  'name': s['name'],
                  'phone_number': s['phone_number'],
                  'age': s['age'],
                })
            .toList();

        StudetntsWithoutTeachers = students; // تحديث الحالة الداخلية
        return students; // إرجاع البيانات
      } else {
        throw Exception('فشل جلب البيانات، رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      // print("Error fetching users without teacher: $e");
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<List<dynamic>> get_teachers(int? daoraId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    dio.options.headers["authorization"] = "Bearer $token";
    var url = '${baseUrl}show_all_teachers';

    try {
      var response = await dio.post(
        url,
        data: {"daora_id": daoraId},
      );

      // print('response in get teachers is : $response');

      if (response.statusCode == 500) {
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }

      TeachersList = response.data; // تحديث الحالة الداخلية
      return response.data; // إرجاع البيانات
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<Map<String, dynamic>> updateUserData({
    required int userId,
    required String name,
    required String phone,
    required int age,

    List<int>? chapters,
  }) async {

    var url = '${baseUrl}update_user/$userId';

    final data = {
      'name': name,
      'phone_number': phone,
      'age': age.toString(),
    };

    if (chapters != null) {
      data['ended_quraan_in_aukaf'] = jsonEncode(chapters);
    }

    var formData = FormData.fromMap(data);

    try {
      var response = await dio.post(url, data: formData);

      // print('response is : $response');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'تم تحديث البيانات بنجاح ✅'};
      }
      // معالجة باقي الأخطاء كرسائل فشل
      else if (response.statusCode == 500) {
        return {'success': false, 'message': 'حدث خطأ داخلي في الخادم'};
      } else if (response.statusCode == 403 || response.statusCode == 400) {
        return {
          'success': false,
          'message': response.data['messages'] ?? 'فشل تحديث البيانات'
        };
      } else {
        return {
          'success': false,
          'message': 'فشل التحديث، رمز الحالة: ${response.statusCode}'
        };
      }
    } catch (e) {
      // print('e is : $e');
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم، تحقق من الإنترنت'
      };
    }
  }

  get_ended_parts() async {
    if (ended_parts == null) {
      return ended_parts;
    }
  }

  get_notifications() async {
    if (notifications == null) {
      return notifications;
    }
  }
}
