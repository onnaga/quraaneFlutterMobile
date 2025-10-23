// ✅ تم تحديث هذا الملف بالكامل لتطبيق منطق الحذف الجزئي للبيانات المتزامنة بنجاح
import 'dart:convert';
import 'dart:io';
import 'package:masjed/state/user.dart';
import 'package:path_provider/path_provider.dart';

class OfflineSyncService {
  // =================================================================
  // دوال تحديد مسارات الملفات
  // =================================================================

  Future<File> _getPendingQuranFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/pending_quran_submissions.json');
  }

  Future<File> _getPendingHadithFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/pending_hadith_submissions.json');
  }

  Future<File> _getPendingActivityFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/pending_activity_submissions.json');
  }

  Future<File> _getPendingNotesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/pending_notes_submissions.json');
  }

  // =================================================================
  // دوال حفظ البيانات في الكاش (عند عدم وجود انترنت)
  // هذه الدوال تبقى كما هي دون تغيير
  // =================================================================

  Future<void> saveQuranSubmissionToCache(Map<String, dynamic> dataToSave) async {
    try {
      final file = await _getPendingQuranFile();
      List<dynamic> existingSubmissions = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          existingSubmissions = jsonDecode(contents);
        }
      }
      existingSubmissions.add(dataToSave);
      await file.writeAsString(jsonEncode(existingSubmissions));
      // print("✅ Quran submission saved to cache.");
    } catch (e) {
      // print("❌ Failed to save Quran submission: $e");
      rethrow;
    }
  }

  Future<void> saveHadithSubmissionToCache(Map<String, dynamic> dataToSave) async {
    try {
      final file = await _getPendingHadithFile();
      List<dynamic> existingSubmissions = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          existingSubmissions = jsonDecode(contents);
        }
      }
      existingSubmissions.add(dataToSave);
      await file.writeAsString(jsonEncode(existingSubmissions));
      // print("✅ Hadith submission saved to cache.");
    } catch (e) {
      // print("❌ Failed to save Hadith submission: $e");
      rethrow;
    }
  }

  Future<void> saveActivitySubmissionToCache(Map<String, dynamic> dataToSave) async {
    try {
      final file = await _getPendingActivityFile();
      List<dynamic> existingSubmissions = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          existingSubmissions = jsonDecode(contents);
        }
      }
      existingSubmissions.add(dataToSave);
      await file.writeAsString(jsonEncode(existingSubmissions));
      // print("✅ Activity submission saved to cache.");
    } catch (e) {
      // print("❌ Failed to save Activity submission: $e");
      rethrow;
    }
  }

  Future<void> saveNoteSubmissionToCache(Map<String, dynamic> dataToSave) async {
    try {
      final file = await _getPendingNotesFile();
      List<dynamic> existingSubmissions = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          existingSubmissions = jsonDecode(contents);
        }
      }
      existingSubmissions.add(dataToSave);
      await file.writeAsString(jsonEncode(existingSubmissions));
      // print("✅ Note submission saved to cache.");
    } catch (e) {
      // print("❌ Failed to save Note submission: $e");
      rethrow;
    }
  }

  // =================================================================
  // دالة المزامنة الشاملة (تبقى كما هي)
  // =================================================================

  Future<void> syncAllPendingData(User user) async {
    // print("🚀 Starting comprehensive sync for all pending data...");
    
    await sendPendingQuranSubmissions(user);
    await sendPendingHadithSubmissions(user);
    await sendPendingActivitySubmissions(user);
    await sendPendingNotesSubmissions(user);
    
    // print("✅ Comprehensive sync finished.");
  }

  // =================================================================
  // دوال إرسال البيانات المحفوظة (عند عودة الانترنت)
  // -- تم تعديل المنطق هنا --
  // =================================================================

  Future<bool> sendPendingQuranSubmissions(User userProvider) async {
    try {
      final file = await _getPendingQuranFile();
      if (!await file.exists()) return true;

      final contents = await file.readAsString();
      if (contents.isEmpty || contents == "[]") return true;

      final submissions = List<Map<String, dynamic>>.from(jsonDecode(contents));
      if (submissions.isEmpty) return true;

      // print("🔄 Sending ${submissions.length} pending Quran submissions...");

      final List<Future<bool>> futureSubmissions = submissions.map((submission) {
        return userProvider.add_latest_quraan_hadith(
          submission['userId'],
          List<dynamic>.from(submission['payload']),
          true, // isQuran
        );
      }).toList();

      final results = await Future.wait(futureSubmissions);
      
      // --- بداية التغيير الرئيسي ---
      // إنشاء قائمة جديدة لتخزين الطلبات التي فشلت فقط
      final List<Map<String, dynamic>> failedSubmissions = [];
      for (int i = 0; i < submissions.length; i++) {
        if (results[i] == false) {
          // إذا فشل الطلب، أضف البيانات الأصلية إلى قائمة الفاشلة
          failedSubmissions.add(submissions[i]);
        }
      }

      if (failedSubmissions.isEmpty) {
        // نجحت جميع الطلبات، احذف الملف بالكامل
        await file.delete();
        // print("✅ All pending Quran submissions sent successfully. Cache cleared.");
      } else {
        // فشلت بعض الطلبات، أعد كتابة الطلبات الفاشلة فقط في الملف
        await file.writeAsString(jsonEncode(failedSubmissions));
        // print("⚠️ ${failedSubmissions.length} Quran submissions failed. Successful ones removed, failed ones kept in cache.");
      }
      // --- نهاية التغيير الرئيسي ---

      // نرجع 'صحيح' طالما أن عملية المزامنة نفسها (قراءة، إرسال، كتابة) تمت بدون أخطاء فادحة
      return true;
    } catch (e) {
      // print("❌ Critical error during sending pending Quran submissions: $e");
      return false;
    }
  }

  Future<bool> sendPendingHadithSubmissions(User userProvider) async {
    try {
      final file = await _getPendingHadithFile();
      if (!await file.exists()) return true;

      final contents = await file.readAsString();
      if (contents.isEmpty || contents == "[]") return true;

      final submissions = List<Map<String, dynamic>>.from(jsonDecode(contents));
      if (submissions.isEmpty) return true;

      // print("🔄 Sending ${submissions.length} pending Hadith submissions...");

      final List<Future<bool>> futureSubmissions = submissions.map((submission) {
        return userProvider.add_latest_quraan_hadith(
          submission['userId'],
          List<dynamic>.from(submission['payload']),
          false, // isQuran
        );
      }).toList();

      final results = await Future.wait(futureSubmissions);

      // --- تطبيق نفس المنطق الجديد هنا ---
      final List<Map<String, dynamic>> failedSubmissions = [];
      for (int i = 0; i < submissions.length; i++) {
        if (results[i] == false) {
          failedSubmissions.add(submissions[i]);
        }
      }

      if (failedSubmissions.isEmpty) {
        await file.delete();
        // print("✅ All pending Hadith submissions sent successfully. Cache cleared.");
      } else {
        await file.writeAsString(jsonEncode(failedSubmissions));
        // print("⚠️ ${failedSubmissions.length} Hadith submissions failed. Successful ones removed, failed ones kept in cache.");
      }
      // --- نهاية المنطق الجديد ---

      return true;
    } catch (e) {
      // print("❌ Critical error during sending pending Hadith submissions: $e");
      return false;
    }
  }

  Future<bool> sendPendingActivitySubmissions(User userProvider) async {
    try {
      final file = await _getPendingActivityFile();
      if (!await file.exists()) return true;

      final contents = await file.readAsString();
      if (contents.isEmpty || contents == "[]") return true;

      final submissions = List<Map<String, dynamic>>.from(jsonDecode(contents));
      if (submissions.isEmpty) return true;

      // print("🔄 Sending ${submissions.length} pending Activity submissions...");

      final List<Future<bool>> futureSubmissions = submissions.map((submission) {
        return userProvider.add_latest_activity(
          submission['userId'],
          List<dynamic>.from(submission['payload']),
        );
      }).toList();

      final results = await Future.wait(futureSubmissions);

      // --- تطبيق نفس المنطق الجديد هنا ---
      final List<Map<String, dynamic>> failedSubmissions = [];
      for (int i = 0; i < submissions.length; i++) {
        if (results[i] == false) {
          failedSubmissions.add(submissions[i]);
        }
      }

      if (failedSubmissions.isEmpty) {
        await file.delete();
        // print("✅ All pending Activity submissions sent successfully. Cache cleared.");
      } else {
        await file.writeAsString(jsonEncode(failedSubmissions));
        // print("⚠️ ${failedSubmissions.length} Activity submissions failed. Successful ones removed, failed ones kept in cache.");
      }
      // --- نهاية المنطق الجديد ---

      return true;
    } catch (e) {
      // print("❌ Critical error during sending pending Activity submissions: $e");
      return false;
    }
  }

  Future<bool> sendPendingNotesSubmissions(User userProvider) async {
    try {
      final file = await _getPendingNotesFile();
      if (!await file.exists()) return true;

      final contents = await file.readAsString();
      if (contents.isEmpty || contents == "[]") return true;

      final submissions = List<Map<String, dynamic>>.from(jsonDecode(contents));
      if (submissions.isEmpty) return true;

      // print("🔄 Sending ${submissions.length} pending Notes submissions...");

      final List<Future<bool>> futureSubmissions = submissions.map((submission) {
        return userProvider.add_latest_notes(
          submission['userId'],
          submission['note'],
          submission['lpoint'],
        );
      }).toList();

      final results = await Future.wait(futureSubmissions);

      // --- تطبيق نفس المنطق الجديد هنا ---
      final List<Map<String, dynamic>> failedSubmissions = [];
      for (int i = 0; i < submissions.length; i++) {
        if (results[i] == false) {
          failedSubmissions.add(submissions[i]);
        }
      }

      if (failedSubmissions.isEmpty) {
        await file.delete();
        // print("✅ All pending Notes submissions sent successfully. Cache cleared.");
      } else {
        await file.writeAsString(jsonEncode(failedSubmissions));
        // print("⚠️ ${failedSubmissions.length} Notes submissions failed. Successful ones removed, failed ones kept in cache.");
      }
      // --- نهاية المنطق الجديد ---

      return true;
    } catch (e) {
      // print("❌ Critical error during sending pending Notes submissions: $e");
      return false;
    }
  }
}