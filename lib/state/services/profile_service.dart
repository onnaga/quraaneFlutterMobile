import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masjed/models/objects.dart';
import 'api_client.dart';

class ProfileService {
  final Dio _dio = ApiClient().dio;
  final String _baseUrl = ApiClient().baseUrl;

  Future<Map<String, dynamic>> fetchScore(
      int privilege, int userId, String token) async {
    try {
      final url = '${_baseUrl}get_score';
      final formData = (privilege == 2 || privilege == 3 || privilege == 4)
          ? FormData.fromMap({'id': userId})
          : null;

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
            headers: {"authorization": "Bearer $token"},
            validateStatus: (_) => true),
      );

      if (response.statusCode == 500) {
        return {'success': false, 'message': 'مشكلة في الخادم'};
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': response.data['message']?.toString() ?? "غير مصرح"
        };
      }

      final points = response.data['points'];
      int parseInt(dynamic val) => int.tryParse(val?.toString() ?? '') ?? 0;

      return {
        'success': true,
        'message': 'تمت عملية جلب البيانات',
        'q_points': parseInt(points?['q_points']),
        'h_points': parseInt(points?['h_points']),
        'a_points': parseInt(points?['a_points']),
        'l_points': parseInt(points?['l_points']),
        'missing_days': parseInt(response.data['missing_days']),
        'ended_parts':
            jsonDecode(response.data['ended_quraan_in_aukaf'] ?? "[]"),
      };
    } catch (e, st) {
      debugPrint("Error in fetchScore: $e\n$st");
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  Future<reciveLatest?> fetchLatest(
      int privilege, int userId, String token) async {
    try {
      String url = (privilege == 2 || privilege == 3)
          ? '${_baseUrl}get_latest_for_student?user_id=$userId'
          : '${_baseUrl}get_latest_for_student';

      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 200) {
        dynamic data = response.data;
        if (data is String) {
          if (data.trim().isEmpty) return null;
          data = jsonDecode(data);
        }

        if (data == null) return null;

        if (data is List) {
          if (data.isEmpty || data[0] == null) return null;
          return reciveLatest.fromJson(data[0]);
        } else if (data is Map) {
          if (data.isEmpty) return null;
          return reciveLatest.fromJson(Map<String, dynamic>.from(data));
        }
        return null;
      } else {
        throw Exception('فشل في جلب البيانات من الخادم');
      }
    } catch (e, st) {
      debugPrint("Error in fetchLatest: $e\n$st");
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchRank(
      bool global, int daoraId, String token) async {
    try {
      var url = global
          ? '${_baseUrl}get_rank_masjed'
          : '${_baseUrl}get_rank_my_group';

      var response = await _dio.get(
        url,
        queryParameters: global ? {'daora_id': daoraId} : null,
        options: Options(
            headers: {"authorization": "Bearer $token"},
            validateStatus: (i) => true),
      );

      if (response.statusCode == 500) {
        return {'success': false, 'message': 'مشكلة في الخادم'};
      }

      if (response.statusCode == 401) {
        return {'success': false, 'message': response.data['message']};
      }

      List<OneUserRank> rankUsers = [];
      List<HalakaRank> rankHalakas = [];

      var studentsData = response.data['students'] ?? [];
      var halakasData = response.data['halakas'] ?? [];

      studentsData.forEach((item) {
        rankUsers.add(OneUserRank.fromJson(item));
      });
      rankUsers.sort((a, b) => b.points.compareTo(a.points));

      halakasData.forEach((item) {
        rankHalakas.add(HalakaRank.fromJson(item));
      });

      return {
        'success': true,
        'rankUsers': rankUsers,
        'rankHalakas': rankHalakas
      };
    } catch (e, st) {
      debugPrint("Error in fetchRank: $e\n$st");
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  Future<bool> updateHalakaName(int halakaId, String name, String token) async {
    try {
      var url = '${_baseUrl}update_halaka_name';
      var response = await _dio.post(url,
          data: {'halaka_id': halakaId, 'name': name},
          options: Options(
              headers: {"authorization": "Bearer $token"},
              validateStatus: (_) => true));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error in updateHalakaName: $e");
      return false;
    }
  }

  Future<bool> changeHalakaTeacher(
      int halakaId, int newTeacherId, String token) async {
    try {
      var url = '${_baseUrl}change_halaka_teacher';
      var response = await _dio.post(url,
          data: {'halaka_id': halakaId, 'new_teacher_id': newTeacherId},
          options: Options(
              headers: {"authorization": "Bearer $token"},
              validateStatus: (_) => true));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error in changeHalakaTeacher: $e");
      return false;
    }
  }

  Future<bool> deleteHalaka(int halakaId, String token) async {
    try {
      var url = '${_baseUrl}delete_halaka/$halakaId';
      var response = await _dio.delete(url,
          options: Options(
              headers: {"authorization": "Bearer $token"},
              validateStatus: (_) => true));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error in deleteHalaka: $e");
      return false;
    }
  }

  Future<bool> addWantingStudents(
      List<int> watingStudents, bool isGlobal, String token) async {
    var url = '${_baseUrl}add_wanting_students';
    Map<String, dynamic> requestData = {
      'students': watingStudents,
      'glob': isGlobal
    };

    try {
      var response = await _dio.post(url,
          data: requestData,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشلت العملية، رمز الخطأ: ${response.statusCode}');
      }
      return true;
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<List<TestData>> getTests(int daoraId, String token) async {
    var url = '${_baseUrl}show_tests?daora_id=$daoraId';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');

      List<TestData> testsList = [];
      response.data['tests'].forEach((item) {
        testsList.add(TestData.fromJson(item));
      });
      return testsList;
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<List<TestUserAccepters>> showTestAccepters(
      int testId, String token) async {
    var url = '${_baseUrl}show_test_accepters/$testId';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');

      List<TestUserAccepters> userAccepters = [];
      response.data.forEach((item) {
        userAccepters.add(TestUserAccepters.fromJson(item));
      });
      return userAccepters;
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<Map<String, dynamic>> updateTestAccepterData(
      int testId,
      int userId,
      List<int> thePartToTestIn,
      String rating,
      String notes,
      String token) async {
    var url = '${_baseUrl}update_test_accepter_data/$testId/$userId';
    var formData = FormData.fromMap({
      'the_part_to_test_in': thePartToTestIn.toString(),
      'rating': rating.toString(),
      'notes': notes,
    });

    var response = await _dio.post(url,
        data: formData,
        options: Options(
            headers: {"authorization": "Bearer $token"},
            validateStatus: (i) => true));

    if (response.statusCode == 500)
      return {'success': false, 'message': 'مشكلة في الخادم'};
    if (response.statusCode == 401)
      return {'success': false, 'message': response.data['message']};

    try {
      if (response.data is String &&
          response.data.toString().contains('SQLSTATE[22007]:')) {
        return {
          'success': false,
          'message': 'أدخل رقما من 1 إلى 100 في خانة التقييم'
        };
      }
    } catch (_) {}

    return {'success': true};
  }

  Future<bool> updateAukafTestsAfterTest(
      int testId,
      int userId,
      List<int> thePartToTestIn,
      String rating,
      String notes,
      String token) async {
    var url = '${_baseUrl}update_aukaf_tests_after_the_test/$testId/$userId';

    try {
      var response = await _dio.post(url,
          data: {
            'the_part_to_test_in': thePartToTestIn,
            'rating': rating,
            'notes': notes
          },
          options: Options(headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          }));

      if (response.statusCode == 500) {
        if (response.data is String &&
            response.data.toString().contains('SQLSTATE[22007]')) {
          throw Exception("أدخل التاريخ بصيغة صحيحة.");
        }
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      }
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');

      return response.statusCode == 200 && response.data['status'] == 'success';
    } catch (e) {
      throw Exception(e.toString().contains('SocketException')
          ? 'فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.'
          : e.toString());
    }
  }

  Future<Map<String, List<TestUserAccepters>>> showSuccessStudentsInTest(
      int testId, String token) async {
    var url = '${_baseUrl}show_success_students_in_test/$testId';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));

      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');

      List<TestUserAccepters> successUsers = [];
      List<TestUserAccepters> failUsers = [];

      response.data['success_users'].forEach((item) {
        successUsers.add(TestUserAccepters.fromJson(item));
      });

      response.data['fail_users'].forEach((item) {
        failUsers.add(TestUserAccepters.fromJson(item));
      });

      return {'success_users': successUsers, 'fail_users': failUsers};
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> takeStudent(int userId, String token) async {
    var url = '${_baseUrl}take_student?user_id=$userId';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> deleteTest(int testId, String token) async {
    var url = '${_baseUrl}delete_test/$testId';
    try {
      var response = await _dio.delete(url,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> addNewTest(
      String at, String notes, bool isAukaf, int daoraId, String token) async {
    final url = '${_baseUrl}add_new_test';
    final formData = FormData.fromMap({
      'End_time': at,
      'notes': notes,
      'aukaf': isAukaf ? 1 : 0,
      'daora_id': daoraId,
    });

    try {
      final response = await _dio.post(url,
          data: formData,
          options: Options(
              headers: {'Authorization': 'Bearer $token'},
              validateStatus: (status) => status != null && status < 500));

      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw Exception(response.data['message'] ?? 'حدثت مشكلة غير معروفة');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ??
            'حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
      } else {
        throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  Future<bool> makeAukafTestForSuccessStudents(
      int testId, String at, String notes, String token) async {
    final url = '${_baseUrl}make_aukaf_test_for_success_students/$testId';
    final formData = FormData.fromMap({'End_time': at, 'notes': notes});

    try {
      final response = await _dio.post(url,
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> acceptTest(int testId, String token) async {
    var url = '${_baseUrl}accept_test/$testId';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> acceptTestForStudent(
      int testId, int studentId, String token) async {
    var url = '${_baseUrl}accept_test_for_student/$testId';
    try {
      var response = await _dio.post(url,
          data: {'student_id': studentId},
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 400 ||
          response.statusCode == 409)
        throw Exception(response.data['error'] ??
            response.data['message'] ??
            'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ??
            e.response!.data['message'] ??
            'حدث خطأ');
      }
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> deleteAcceptedTest(int testId, String token) async {
    var url = '${_baseUrl}delete_accepted_test/$testId';
    try {
      var response = await _dio.delete(url,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<bool> deleteAcceptedTestForStudent(
      int testId, int studentId, String token) async {
    var url = '${_baseUrl}delete_accepted_test_for_student/$testId';
    try {
      var response = await _dio.delete(url,
          data: {'student_id': studentId},
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 400)
        throw Exception(response.data['error'] ??
            response.data['message'] ??
            'غير مصرح لك بالقيام بهذه العملية.');
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['error'] ??
            e.response!.data['message'] ??
            'حدث خطأ');
      }
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> showReports(String token) async {
    var url = '${_baseUrl}show_reports';
    try {
      var response = await _dio.get(url,
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return response.data;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<List<Map<String, dynamic>>> showUsersWithoutTeacher(
      int daoraId, String token) async {
    try {
      var url = '${_baseUrl}show_users_without_teacher';
      var response = await _dio.get(url,
          queryParameters: {"daora_id": daoraId},
          options: Options(headers: {"Authorization": "Bearer $token"}));

      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((s) => {
                  'user_id': s['user_id'],
                  'ended_quraan_in_aukaf': s['ended_quraan_in_aukaf'],
                  'name': s['name'],
                  'phone_number': s['phone_number'],
                  'age': s['age'],
                })
            .toList();
      } else {
        throw Exception('فشل جلب البيانات، رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<List<dynamic>> getTeachers(int? daoraId, String token) async {
    var url = '${_baseUrl}show_all_teachers';
    try {
      var response = await _dio.post(url,
          data: {"daora_id": daoraId},
          options: Options(headers: {"authorization": "Bearer $token"}));
      if (response.statusCode == 500)
        throw Exception('حدثت مشكلة في الخادم، يرجى المحاولة لاحقاً.');
      if (response.statusCode == 401)
        throw Exception(
            response.data['message'] ?? 'غير مصرح لك بالقيام بهذه العملية.');
      return response.data;
    } catch (e) {
      throw Exception('فشل الاتصال بالخادم، تحقق من اتصالك بالإنترنت.');
    }
  }

  Future<Map<String, dynamic>> updateUserData(
      int userId, Map<String, dynamic> data) async {
    var url = '${_baseUrl}update_user/$userId';
    var formData = FormData.fromMap(data);
    try {
      var response = await _dio.post(url, data: formData);
      if (response.statusCode == 200)
        return {'success': true, 'message': 'تم تحديث البيانات بنجاح ✅'};
      if (response.statusCode == 500)
        return {'success': false, 'message': 'حدث خطأ داخلي في الخادم'};
      if (response.statusCode == 403 || response.statusCode == 400)
        return {
          'success': false,
          'message': response.data['messages'] ?? 'فشل تحديث البيانات'
        };
      return {
        'success': false,
        'message': 'فشل التحديث، رمز الحالة: ${response.statusCode}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم، تحقق من الإنترنت'
      };
    }
  }
}
