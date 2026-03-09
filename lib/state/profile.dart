import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:masjed/models/objects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/profile_service.dart';

class Profile extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

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
  List<HalakaRank>? RankHalakas;
  List<TestData>? TestsList;
  List<TestUserAccepters> TestUseraccepters = [];
  List<TestUserAccepters> success_users = [];
  List<TestUserAccepters> fail_users = [];
  List<dynamic>? ended_parts;
  List<User_Notification>? notifications;

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

  int parseInt(dynamic val) => int.tryParse(val?.toString() ?? '') ?? 0;

  Future<Map<String, dynamic>> get_score(int privilege, int userId) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');

    if (token == null || token == "null") {
      return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
    }

    final result = await _profileService.fetchScore(privilege, userId, token);

    if (result['success'] == true) {
      q_points = result['q_points'] ?? 0;
      h_points = result['h_points'] ?? 0;
      a_points = result['a_points'] ?? 0;
      l_points = result['l_points'] ?? 0;
      total_points = q_points + h_points + a_points - l_points;
      missing_days = result['missing_days'] ?? 0;
      ended_parts = result['ended_parts'];
      notifyListeners();
    }

    return result;
  }

  Future<reciveLatest?> get_Latest(int privilege, int userId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('المستخدم غير مسجل دخوله');
    }

    recivelatest = await _profileService.fetchLatest(privilege, userId, token);
    notifyListeners();
    return recivelatest;
  }

  Future<Map<String, dynamic>> get_rank(bool global, int daoraId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
    }

    final result = await _profileService.fetchRank(global, daoraId, token);

    RankUsers = [];
    RankHalakas = [];

    if (result['success'] == true) {
      RankUsers = result['rankUsers'];
      RankHalakas = result['rankHalakas'];
      notifyListeners();
    }

    return result;
  }

  Future<bool> update_halaka_name(int halakaId, String name) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") return false;

    bool success =
        await _profileService.updateHalakaName(halakaId, name, token);
    if (success && RankHalakas != null) {
      int index = RankHalakas!.indexWhere((h) => h.id == halakaId);
      if (index != -1) {
        RankHalakas![index].halaka_name = name;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> change_halaka_teacher(int halakaId, int newTeacherId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") return false;

    return await _profileService.changeHalakaTeacher(
        halakaId, newTeacherId, token);
  }

  Future<bool> add_wanting_students(
      List<int> watingStudents, bool isGlobal) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.addWantingStudents(
        watingStudents, isGlobal, token);
  }

  Future<bool> deleteHalaka(int halakaId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") return false;

    return await _profileService.deleteHalaka(halakaId, token);
  }

  Future<List<TestData>> get_tests(int daoraId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    TestsList = await _profileService.getTests(daoraId, token);
    notifyListeners();
    return TestsList ?? [];
  }

  Future<List<TestUserAccepters>> show_test_accepters(int testId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    TestUseraccepters = await _profileService.showTestAccepters(testId, token);
    notifyListeners();
    return TestUseraccepters;
  }

  Future<bool> update_test_accepter_data(
      BuildContext context,
      int testId,
      int userId,
      List<int> thePartToTestIn,
      String rating,
      String notes) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") return false;

    final result = await _profileService.updateTestAccepterData(
        testId, userId, thePartToTestIn, rating, notes, token);

    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'خطأ'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }

    return true;
  }

  Future<bool> update_aukaf_tests_after_the_test(
    int testId,
    int userId,
    List<int> thePartToTestIn,
    String rating,
    String notes,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.updateAukafTestsAfterTest(
        testId, userId, thePartToTestIn, rating, notes, token);
  }

  Future<Map<String, List<TestUserAccepters>>> show_success_students_in_test(
      int testId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    final result =
        await _profileService.showSuccessStudentsInTest(testId, token);

    success_users = result['success_users'] ?? [];
    fail_users = result['fail_users'] ?? [];
    notifyListeners();

    return result;
  }

  Future<bool> take_student(int userId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.takeStudent(userId, token);
  }

  Future<bool> delete_test(int testId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.deleteTest(testId, token);
  }

  Future<bool> add_new_test(
      String at, String notes, bool isAukaf, int daoraId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.addNewTest(at, notes, isAukaf, daoraId, token);
  }

  Future<bool> make_aukaf_test_for_success_students(
      int testId, String at, String notes) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.makeAukafTestForSuccessStudents(
        testId, at, notes, token);
  }

  Future<bool> accept_test(int testId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.acceptTest(testId, token);
  }

  Future<bool> accept_test_for_student(int testId, int studentId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.acceptTestForStudent(testId, studentId, token);
  }

  Future<bool> delete_accepted_test(int testId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.deleteAcceptedTest(testId, token);
  }

  Future<bool> delete_accepted_test_for_student(
      int testId, int studentId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    return await _profileService.deleteAcceptedTestForStudent(
        testId, studentId, token);
  }

  Future<List<dynamic>> show_reports() async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    ReportsList = await _profileService.showReports(token);
    notifyListeners();
    return ReportsList ?? [];
  }

  Future<List<Map<String, dynamic>>> show_users_without_teacher(
      int daoraId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    StudetntsWithoutTeachers =
        await _profileService.showUsersWithoutTeacher(daoraId, token);
    notifyListeners();
    return StudetntsWithoutTeachers as List<Map<String, dynamic>>;
  }

  Future<List<dynamic>> get_teachers(int? daoraId) async {
    final preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == null || token == "null") {
      throw Exception('جلسة المستخدم منتهية، يرجى تسجيل الدخول مرة أخرى.');
    }

    TeachersList = await _profileService.getTeachers(daoraId, token);
    notifyListeners();
    return TeachersList ?? [];
  }

  Future<Map<String, dynamic>> updateUserData({
    required int userId,
    required String name,
    required String phone,
    required int age,
    List<int>? chapters,
  }) async {
    Map<String, dynamic> data = {
      'name': name,
      'phone_number': phone,
      'age': age.toString(),
    };

    if (chapters != null) {
      data['ended_quraan_in_aukaf'] = jsonEncode(chapters);
    }

    return await _profileService.updateUserData(userId, data);
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
