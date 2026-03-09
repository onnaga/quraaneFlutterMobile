import 'dart:io';
import 'package:flutter/material.dart';
import 'package:masjed/models/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'services/user_service.dart';

class User extends ChangeNotifier {
  final UserService _userService = UserService();

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

  Future<bool> login(String username, String password) async {
    make_all_null();
    final result = await _userService.login(username, password);

    if (result['success']) {
      final responseData = result['data'];
      token = responseData['token'].toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token as String);

      id = responseData['id'];
      this.username = responseData['name'];
      privilege = responseData['privilege'];
      teache_name = responseData['teache_name'];

      int daoraIdValue = responseData['daora_id'] ?? 0;
      await prefs.setInt("currentDaoraId", daoraIdValue);
      await prefs.setInt("privilege", privilege!);
      daoraId = daoraIdValue;

      details = {
        'phone': responseData['phone_number'],
        'age': responseData['age'],
        'job': responseData['job'],
        'address': responseData['address'],
        'family_status': responseData['family_status'],
      };

      notifyListeners();
      return true;
    }
    return false;
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
    final result = await _userService.register(username, password, phone, age,
        chapters, daoraId, job, address, familyStatus);

    if (result['success']) {
      final responseData = result['data'];
      token = responseData['token'].toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token as String);

      id = responseData['id'];
      this.username = responseData['name'];
      privilege = responseData['privilege'];

      details = {
        'phone': responseData['phone_number'],
        'age': responseData['age'],
        'job': responseData['job'],
        'address': responseData['address'],
        'family_status': responseData['family_status'],
      };

      notifyListeners();
      return true;
    }
    return false;
  }

  /// تقوم بتبديل صلاحية الأستاذ وترجع خريطة بالنتيجة.
  Future<Map<String, dynamic>> toggleTeacherPrivilege(int targetUserId) async {
    if (token == null)
      return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
    return await _userService.toggleTeacherPrivilege(targetUserId, token!);
  }

  Future<Map<String, dynamic>> login_via_token() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString('token');

    if (token == null || token == "null" || token!.isEmpty) {
      throw Exception('Token not found');
    }

    final result = await _userService.loginViaToken(token!);

    if (result['success']) {
      final responseData = result['data'];
      id = responseData['id'];
      username = responseData['name'];
      privilege = responseData['privilege'];
      teache_name = responseData['teache_name'];
      image_hash = responseData['photo_hash'];
      int daoraIdValue = responseData['daora_id'] ?? 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("currentDaoraId", daoraIdValue);
      await prefs.setInt("privilege", privilege!);
      daoraId = daoraIdValue;

      details = {
        'phone': responseData['phone_number'],
        'age': responseData['age'],
        'job': responseData['job'],
        'address': responseData['address'],
        'family_status': responseData['family_status'],
      };

      notifyListeners();
      return {'daoraId': daoraIdValue};
    }
    throw Exception('فشل استرجاع البيانات.');
  }

  Future<UserToShowProfile> get_user_info(int userId) async {
    if (token == "null" || token == null) {
      throw Exception('أنت غير مسجل الدخول');
    }
    return await _userService.getUserInfo(userId, token!);
  }

  Future<File?> getImage(String id, imageHashSended) async {
    make_all_null();
    if (imageHashSended != null) {
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      File file = File(
          path.join(documentDirectory.path, path.basename(imageHashSended!)));

      if (await file.exists()) {
        image = file;
      }
    } else {
      image = null;
    }
    return image;
  }

  Future<bool> resetPassword(
      BuildContext context, String oldPassword, String newPassword) async {
    if (token == null) return false;

    final result =
        await _userService.resetPassword(oldPassword, newPassword, token!);

    if (result['success']) {
      token = result['token'];
      Provider.of<SharedPreferences>(context, listen: false).remove('token');
      Provider.of<SharedPreferences>(context, listen: false)
          .setString('token', token as String);
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'خطأ'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
  }

  Future<bool> update_details(int age, String phoneNumber, String job,
      String address, String? familyStatus) async {
    if (token == null) return false;

    final result = await _userService.updateDetails(
        age, phoneNumber, job, address, familyStatus, token!);
    if (result['success']) {
      details = {
        'phone': phoneNumber,
        'age': age,
        'job': job,
        'address': address,
        'family_status': familyStatus
      };
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, List<String>>> fetchSuggestions() async {
    return await _userService.fetchSuggestions();
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
    if (token == null) return false;
    return await _userService.addAdmin(username, password, privilege, daoraId,
        job, address, familyStatus, token!);
  }

  Future<bool> deleteLatestQuranItem(
      int userId, Map<String, dynamic> itemToDelete) async {
    if (token == null) throw Exception('المستخدم غير مسجل دخوله');
    return await _userService.deleteLatestItem(
        userId, itemToDelete, 'quraan', token!);
  }

  Future<bool> deleteLatestHadithItem(
      int userId, Map<String, dynamic> itemToDelete) async {
    if (token == null) throw Exception('المستخدم غير مسجل دخوله');
    return await _userService.deleteLatestItem(
        userId, itemToDelete, 'hadith', token!);
  }

  Future<bool> deleteLatestActivityItem(
      int userId, Map<String, dynamic> itemToDelete) async {
    if (token == null) throw Exception('المستخدم غير مسجل دخوله');
    return await _userService.deleteLatestItem(
        userId, itemToDelete, 'activity', token!);
  }

  Future<bool> deleteLatestNoteItem(int userId) async {
    if (token == null) throw Exception('المستخدم غير مسجل دخوله');
    return await _userService.deleteLatestNoteItem(userId, token!);
  }

  Future<bool> add_latest_quraan_hadith(
      int userId, List<dynamic> dataToSend, bool quran) async {
    if (token == null) return false;
    return await _userService.addLatestQuranHadith(
        userId, dataToSend, quran, token!);
  }

  Future<bool> add_latest_activity(int userId, List<dynamic> dataToSend) async {
    if (token == null) return false;
    return await _userService.addLatestActivity(userId, dataToSend, token!);
  }

  Future<bool> add_latest_notes(
      int userId, String note, String lostPoint) async {
    if (token == null) return false;
    return await _userService.addLatestNotes(userId, note, lostPoint, token!);
  }

  Future<bool> Delete_user(BuildContext context, userId) async {
    if (token == null) return false;

    final result = await _userService.deleteUser(userId, token!);

    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'خطأ'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> leave_student(userId) async {
    if (token == null)
      return {'success': false, 'message': 'المستخدم غير مسجل دخوله'};
    return await _userService.leaveStudent(userId, token!);
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
