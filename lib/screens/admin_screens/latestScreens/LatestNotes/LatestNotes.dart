// ✅ تم تعديل هذا الملف لإزالة المزامنة التلقائية عند فتح الشاشة

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/state/offline.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class LatestNote extends StatefulWidget {
  final int userId;

  const LatestNote({super.key, required this.userId});

  @override
  State<LatestNote> createState() => _LatestNoteState();
}

class _LatestNoteState extends State<LatestNote> {
  String note = '';
  String lPoint = '0';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ✅ إنشاء كائن من خدمة المزامنة
  final OfflineSyncService offlineService = OfflineSyncService();

  // ❌ تم حذف دالة initState و _initializeAndSync بالكامل
  // لم تعد هذه الشاشة مسؤولة عن بدء المزامنة، لتجنب التكرار.
  // المزامنة ستتم فقط عبر Workmanager أو استدعاء مركزي في التطبيق.

  String? noteValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أضف الملاحظة';
    }
    note = value;
    return null;
  }

  String? lpointValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أضف النقاط المخصومة';
    }
    lPoint = value;
    return null;
  }

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      showStyledSnackBar(context,
          message: 'أدخل جميع الحقول قبل إرسال المعلومات', isError: true);
      return;
    }
    form.save();

    setState(() {
      _isLoading = true;
    });

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    final user = context.read<User>();

    if (isOnline) {
      // ===== الكود في حالة الاتصال بالإنترنت =====
      try {
        // ✅ محاولة مزامنة البيانات القديمة أولاً قبل إضافة الجديد
        // هذا يضمن الترتيب الصحيح للأحداث
        await offlineService.sendPendingNotesSubmissions(user);
        
        bool success = await user.add_latest_notes(widget.userId, note, lPoint);
        if (!mounted) return;
        showStyledSnackBar(context,
            message: success ? 'تم إضافة البيانات' : 'توجد مشكلة في الإضافة',
            isError: !success);
        if (success) {
          form.reset();
        }
      } catch (e) {
        if (!mounted) return;
        showStyledSnackBar(context, message: e.toString(), isError: true);
      }
    } else {
      // ===== الكود في حالة عدم الاتصال بالإنترنت =====
      final submission = {
        'userId': widget.userId,
        'note': note,
        'lpoint': lPoint,
      };

      try {
        await offlineService.saveNoteSubmissionToCache(submission);
        // تسجيل المهمة للعمل مرة واحدة عند توفر الشبكة
        Workmanager().registerOneOffTask(
          "notesSyncTask-${DateTime.now().millisecondsSinceEpoch}", // اسم فريد للمهمة
          "syncAllPendingData", // اسم المهمة العامة للمزامنة
          constraints: Constraints(networkType: NetworkType.connected),
          backoffPolicy: BackoffPolicy.linear, // سياسة لإعادة المحاولة
        );
        if (mounted) {
          showStyledSnackBar(context,
              message: 'تم الحفظ محلياً، سيتم الإرسال عند توفر الإنترنت');
          form.reset();
        }
      } catch (e) {
        if (mounted) {
          showStyledSnackBar(context,
              message: 'فشل حفظ البيانات محلياً', isError: true);
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                const Color.fromARGB(255, 139, 55, 55)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 46, 38, 38).withOpacity(0.6),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  "إضافة ملاحظة جديدة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  validator: noteValidator,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'الملاحظة',
                    prefixIcon:
                        const Icon(Icons.note_add_rounded, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: lpointValidator,
                  style: const TextStyle(color: Colors.black87),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'النقاط المخصومة',
                    labelStyle: const TextStyle(color: Colors.red),
                    prefixIcon:
                        const Icon(Icons.delete_forever, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _isLoading
                    ? const ModernLoader()
                    : SubmitFormButton(submit: submit),
              ],
            ),
          ),
        ),
      ],
    );
  }
}