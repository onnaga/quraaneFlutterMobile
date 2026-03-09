import 'dart:convert';

import 'package:flutter/material.dart';

//         "id": 2,
//         "test_id": 1,
//         "user_id": 11,
//         "the_part_to_test_in": "0",
//         "rating": 0,
//         "notes": "0",
//         "user_name": "o",
//         "test_date": "2025-10-02 09:30:00"

class TestUserAccepters {
  final int test_id;
  final int user_id;
  final String user_name;
  final String notes;
  final String the_part_to_test_in;
  final String rating;
  TestUserAccepters(
      {required this.notes,
      required this.test_id,
      required this.user_id,
      required this.the_part_to_test_in,
      required this.rating,
      required this.user_name});
  TestUserAccepters.fromJson(Map<String, dynamic> json)
      : test_id = json['test_id'] as int,
        user_id = json['user_id'] as int,
        user_name = json['user_name'] as String,
        notes = json['notes'] as String,
        the_part_to_test_in = json['the_part_to_test_in'] as String,
        rating = json['rating'].toString();
}

class UserToShowProfile {
  int id;
  String name;
  String phone_number;
  int age;
  List<int>? ended_quraan;
  String? job_name;
  String? family_status;
  // ✅ هذا الحقل سيمثل "مكان السكن" القادم من address
  String? region;

  UserToShowProfile({
    required this.id,
    required this.name,
    required this.phone_number,
    required this.age,
    this.ended_quraan,
    this.job_name,
    this.family_status,
    this.region,
  });

  factory UserToShowProfile.fromJson(Map<String, dynamic> json) {
    return UserToShowProfile(
      id: json['id'],
      name: json['name'] ?? '',
      phone_number: json['phone_number'] ?? '',
      age: json['age'] ?? 0,
      ended_quraan:
          json['ended_quraan'] != null ? List.from(json['ended_quraan']) : [],
      // ◀️ تعديل: اقرأ من 'job' بدلاً من 'job_name'
      job_name: json['job'],
      family_status: json['family_status'],
      // ◀️ تعديل: اقرأ من 'address' وضعه في 'region'
      region: json['address'],
    );
  }
}

class reciveLatest {
  List<dynamic>? quran = [];
  List<dynamic>? quranHomework = [];
  List<dynamic>? hadith = [];
  List<dynamic>? hadithHomework = [];
  List<dynamic>? activities = [];
  String? note;
  String? LPoints;
  String? createdAt = '';

  reciveLatest({
    this.quran,
    this.quranHomework,
    this.hadith,
    this.hadithHomework,
    this.activities,
    this.note,
    this.LPoints,
    this.createdAt,
  });

  // ✅ دالة مساعدة لتجميع البيانات من 'ghaiban' و 'nazaran'
  List<dynamic> _flattenAndCombine(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> ghaibanItems = data['ghaiban'] ?? [];
      final List<dynamic> nazaranItems = data['nazaran'] ?? [];

      List<dynamic> combinedList = [];

      // إضافة عناصر غيباً مع تحديد نوعها
      for (var item in ghaibanItems) {
        if (item is Map<String, dynamic>) {
          item['type'] = 'ghaiban';
          combinedList.add(item);
        }
      }

      // إضافة عناصر نظراً مع تحديد نوعها
      for (var item in nazaranItems) {
        if (item is Map<String, dynamic>) {
          item['type'] = 'nazaran';
          combinedList.add(item);
        }
      }

      return combinedList;
    } catch (e) {
      // في حال كان الـ JSON بصيغة قديمة (مجرد قائمة)
      try {
        return jsonDecode(jsonString);
      } catch (e2) {
        return [];
      }
    }
  }

  // ✅ تعديل: التحويل من JSON إلى كائن مع فهم البنية الجديدة
  reciveLatest.fromJson(Map<String, dynamic> json) {
    quran = _flattenAndCombine(json['quran']);
    hadith = json['hadith'] == null
        ? []
        : jsonDecode(json['hadith']); // افترضنا أن الحديث لا يزال كما هو
    quranHomework = _flattenAndCombine(json['q_homework']);
    hadithHomework =
        json['h_homework'] == null ? [] : jsonDecode(json['h_homework']);
    activities =
        json['activities'] == null ? [] : jsonDecode(json['activities']);
    createdAt = json['updated_at'] ?? json['created_at'];

    note = (json['note'] == null || json['note'].isEmpty)
        ? note = ''
        : jsonDecode(json['note'])['note'];
    LPoints = json['note'] == null ? "0" : jsonDecode(json['note'])['LPoints'];
  }

  // ✅ تعديل: التحويل من كائن إلى JSON (للتخزين في الكاش) بشكل صحيح
  Map<String, dynamic> toJson() {
    // دالة مساعدة لإعادة بناء الهيكل المتداخل
    String reconstructNestedJson(List<dynamic>? items) {
      if (items == null || items.isEmpty)
        return '{"ghaiban": [], "nazaran": []}';

      Map<String, List<dynamic>> sorted = {'ghaiban': [], 'nazaran': []};
      for (var item in items) {
        if (item is Map<String, dynamic>) {
          final type = item['type'];
          // نزيل النوع قبل التخزين لتجنب تكراره
          final Map<String, dynamic> newItem = Map.from(item)..remove('type');
          if (type == 'nazaran') {
            sorted['nazaran']!.add(newItem);
          } else {
            // الافتراضي هو غيباً
            sorted['ghaiban']!.add(newItem);
          }
        }
      }
      return jsonEncode(sorted);
    }

    return {
      'quran': reconstructNestedJson(quran),
      'hadith': jsonEncode(hadith ?? []),
      'q_homework': reconstructNestedJson(quranHomework),
      'h_homework': jsonEncode(hadithHomework ?? []),
      'activities': jsonEncode(activities ?? []),
      'note': jsonEncode({
        'note': note ?? 'لا يوجد ملاحظة مضافة',
        'LPoints': LPoints ?? "0",
      }),
      'created_at': createdAt ?? '',
    };
  }
}

class TestData {
  final int id;
  final String End_time;
  final int aukaf;
  final String notes;
  final int daoraId;
  final int number; // ✅ الحقل الجديد

  TestData({
    required this.id,
    required this.End_time,
    required this.aukaf,
    required this.notes,
    required this.daoraId,
    required this.number,
  });

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      id: json['id'],
      End_time: json['End_time'],
      aukaf: json['aukaf'],
      notes: json['notes'] ?? '',
      daoraId: json['daora_id'],
      number: json['number'] ?? 0, // ✅ مهم جداً
    );
  }
}

class WantingCheckBox {
  int id;
  bool checked;

  WantingCheckBox({required this.checked, required this.id});
}

class HalakaRank {
  final int id;
  String halaka_name;
  final int teacher_id;
  final String teacher_name;
  final int students_count;

  HalakaRank({
    required this.id,
    required this.halaka_name,
    required this.teacher_id,
    required this.teacher_name,
    required this.students_count,
  });

  factory HalakaRank.fromJson(Map<String, dynamic> json) {
    return HalakaRank(
      id: json['id'] as int? ?? 0,
      halaka_name: json['halaka_name']?.toString() ?? '',
      teacher_id: json['teacher_id'] as int? ?? 0,
      teacher_name: json['teacher_name']?.toString() ?? '',
      students_count: json['students_count'] as int? ?? 0,
    );
  }
}

class OneUserRank {
  final int user_id;
  final String user_name;
  final int points;
  final int teacher_id;
  final int missingDays; // ✅ تمت الإضافة
  final String lastAttendanceStatus; // ✅ تمت الإضافة ('present' or 'absent')

  OneUserRank({
    required this.user_id,
    required this.user_name,
    required this.points,
    required this.teacher_id,
    required this.missingDays, // ✅ تمت الإضافة
    required this.lastAttendanceStatus, // ✅ تمت الإضافة
  });

  // Helper لتحويل قيم قد تكون String أو int أو double إلى int بأمان
  static int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  factory OneUserRank.fromJson(Map<String, dynamic> json) {
    return OneUserRank(
      user_id: _parseInt(json['user_id']),
      teacher_id: _parseInt(json['teacher_id']),
      user_name: (json['user_name'] ?? '').toString(),
      points: _parseInt(json['points']),
      // ✅ استقبال البيانات الجديدة مع قيم افتراضية لمنع الأخطاء
      missingDays: _parseInt(json['missing_days']),
      lastAttendanceStatus: json['last_attendance_status'] ?? 'present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'teacher_id': teacher_id,
      'user_name': user_name,
      'points': points,
      'missing_days': missingDays, // ✅ تمت الإضافة للحفظ في الكاش
      'last_attendance_status':
          lastAttendanceStatus, // ✅ تمت الإضافة للحفظ في الكاش
    };
  }
}

class Points {
  final int q_points;
  final int h_points;
  final int a_points;
  final int l_points;

  Points(
      {required this.q_points,
      required this.h_points,
      required this.a_points,
      required this.l_points});

  Points.fromJson(Map<String, dynamic> json)
      : q_points = json['q_points'] as int,
        h_points = json['h_points'] as int,
        a_points = json['a_points'] as int,
        l_points = json['l_points'] as int;
}

class User_Notification {
  final DateTime date;
  final String sender;
  final String message;
  final bool read;

  const User_Notification(
      {required this.date,
      required this.sender,
      required this.message,
      required this.read});

  User_Notification.fromJson(Map<String, dynamic> json)
      : date = json['date'] as DateTime,
        sender = json['sender'] as String,
        message = json['message'] as String,
        read = json['read'] as bool;

  Map<String, dynamic> toJson() =>
      {'date': date, 'sender': sender, 'message': message, 'read': read};
}

class endedSurah {
  final int num;
  final int from;
  final int to;
  final int mark;
  final int points;

  endedSurah(
      {required this.num,
      required this.from,
      required this.to,
      required this.mark,
      required this.points});
  Map<String, dynamic> toJson() =>
      {'num': num, 'from': from, 'to': to, 'mark': mark, 'points': points};
}

class endedSurahToSend extends Notification {
  int num;
  int from;
  int to;
  int mark;
  int point;
  String type;

  endedSurahToSend({
    required this.num,
    required this.from,
    required this.to,
    required this.mark,
    required this.point,
    this.type = 'ghaiban',
  });

  Map<String, dynamic> toJson() => {
        'num': num,
        'from': from,
        'to': to,
        'mark': mark,
        'point': point,
        'type': type,
      };

  endedSurahToSend copyWith({
    int? num,
    int? from,
    int? to,
    int? mark,
    int? point,
    String? type,
  }) {
    return endedSurahToSend(
      num: num ?? this.num,
      from: from ?? this.from,
      to: to ?? this.to,
      mark: mark ?? this.mark,
      point: point ?? this.point,
      type: type ?? this.type,
    );
  }
}

class homeworkSurahToSend extends Notification {
  int num;
  int from;
  int to;
  String type;
  homeworkSurahToSend({
    required this.num,
    required this.from,
    required this.to,
    this.type = 'ghaiban',
  });

  Map<String, dynamic> toJson() => {
        'num': num,
        'from': from,
        'to': to,
        'type': type,
      };

  homeworkSurahToSend copyWith({
    int? num,
    int? from,
    int? to,
    String? type,
  }) {
    return homeworkSurahToSend(
      num: num ?? this.num,
      from: from ?? this.from,
      to: to ?? this.to,
      type: type ?? this.type,
    );
  }
}

class homeWorkSorah extends Notification {
  final int num;
  final int from;
  final int to;

  homeWorkSorah({required this.num, required this.from, required this.to});
  Map<String, dynamic> toJson() => {
        'num': num,
        'from': from,
        'to': to,
      };
}

class Hadith {
  final int id;
  final int from;
  final int to;
  final int mark;
  final int points;

  const Hadith(
      {required this.id,
      required this.from,
      required this.to,
      required this.mark,
      required this.points});

  Hadith.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        from = json['from'] as int,
        to = json['to'] as int,
        mark = json['mark'] as int,
        points = json['points'] as int;

  Map<String, dynamic> toJson() =>
      {'id': id, 'from': from, 'to': to, 'mark': mark, 'points': points};
}

class Activities {
  String details;
  int points;

  Activities({
    required this.details,
    required this.points,
  });

  Activities.fromJson(Map<String, dynamic> json)
      : details = json['details'] as String,
        points = json['points'] as int;

  Map<String, dynamic> toJson() => {
        'details': details,
        'points': points,
      };

  Activities copyWith({
    String? details,
    int? points,
  }) {
    return Activities(
      details: details ?? this.details,
      points: points ?? this.points,
    );
  }
}

class activitiesToSend extends Notification {
  String name;
  int mark;
  int point;

  activitiesToSend({
    required this.name,
    required this.mark,
    required this.point,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'mark': mark,
        'point': point,
      };

  activitiesToSend copyWith({
    String? name,
    int? mark,
    int? point,
  }) {
    return activitiesToSend(
      name: name ?? this.name,
      mark: mark ?? this.mark,
      point: point ?? this.point,
    );
  }
}
