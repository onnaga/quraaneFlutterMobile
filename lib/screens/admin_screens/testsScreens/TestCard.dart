import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/pulse_loader.dart';

import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/AddTestScreen.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/showSuccesUserInTest.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/showTestAccepters.dart';
import 'package:masjed/screens/admin_screens/testsScreens/actions_for_users_with_tests.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

// 🛑 تأكد من استيراد صفحة الإضافة هنا

// A helper function to handle API calls and show SnackBars, reducing repetition.
void _handleApiCall(
  BuildContext context, {
  required Future<bool> apiCall,
  required String successMessage,
  required String errorMessage,
  VoidCallback? onSuccess,
}) {
  apiCall.then((success) {
    if (success) {
      if (onSuccess != null) {
        onSuccess();
      }
      showStyledSnackBar(context, message: successMessage, isError: false);
    } else {
      showStyledSnackBar(context, message: errorMessage, isError: true);
    }
  });
}

class TestCard extends StatefulWidget {
  final TestData data;
  final Function(Profile profile) methodFromParent;

  const TestCard({
    super.key,
    required this.data,
    required this.methodFromParent,
  });

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);
    final int userPrivilege = user.privilege!;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF9FAFB),
              Color(0xFFE9F7EF),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTestInfo(),
              const SizedBox(height: 20),
              _buildMainActionButton(context, profile),
              const SizedBox(height: 16),
              if (userPrivilege != 1)
                actionsForAdmins(
                  privilege: userPrivilege,
                  date: widget.data.End_time,
                  aukaf: widget.data.aukaf,
                  test_id: widget.data.id,
                  methodFromGrandPa: widget.methodFromParent,
                )
              else
                actionsForUsersWithTests(
                  aukaf: widget.data.aukaf,
                  date: widget.data.End_time,
                  test_id: widget.data.id,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestInfo() {
    final testDate = widget.data.End_time.split(' ')[0];
    final testTime = widget.data.End_time.split(' ')[1].substring(0, 5);
    final testType = widget.data.aukaf == 1 ? '📘 سبر أوقاف' : '📗 سبر ترشيحي';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildInfoRow('🔢 رقم السبر', "${widget.data.id}"),
        _buildInfoRow(' يوم السبر', testDate),
        _buildInfoRow('⏰ حتى الساعة', testTime),
        _buildInfoRow('📖 نوع السبر', testType),
        _buildInfoRow('📝 الملاحظات',
            widget.data.notes.isNotEmpty ? widget.data.notes : "لا يوجد"),
        _buildInfoRow('👥 عدد المتقدمين', "${widget.data.number}"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              "$label : $value",
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E3B32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context, Profile profile) {
    final isTestFinished =
        DateTime.now().isAfter(DateTime.parse(widget.data.End_time));

    if (isTestFinished) {
      return _buildStyledButton(
        text: '📊 عرض النتائج',
        color: Colors.teal,
        onPressed: () async {
          // عرض لودر مؤقت
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: ModernLoader()),
          );

          try {
            final profile = Provider.of<Profile>(context, listen: false);

            // استدعاء الدالة بدون context والحصول على النتائج
            final results =
                await profile.show_success_students_in_test(widget.data.id);
            final successUsers = results['success_users']!;
            final failUsers = results['fail_users']!;

            if (!mounted) return;

            Navigator.pop(context); // إغلاق اللودر
            showStyledSnackBar(context, message: 'تم جلب النتائج بنجاح ✅');

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Showsuccesuserintest(
                successUsers: successUsers,
                failUsers: failUsers,
              ),
            ));
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // إغلاق اللودر
            showStyledSnackBar(context, message: e.toString(), isError: true);
          }
        },
      );
    } else {
      return _buildStyledButton(
        text: '👨‍🎓 عرض المتقدمين',
        color: Colors.blueGrey,
        onPressed: () async {
          // عرض لودر
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: PulseLoader(size: 70)),
          );

          try {
            // استدعاء الدالة بدون context والحصول على البيانات
            final List<TestUserAccepters> accepters =
                await profile.show_test_accepters(widget.data.id);

            if (!mounted) return;

            Navigator.pop(context); // إغلاق اللودر

            showStyledSnackBar(context, message: 'تم جلب المتقدمين بنجاح ✅');

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserTestListViewAccepters(
                initialData: accepters,
                testId: widget.data.id,
              ),
            ));
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // إغلاق اللودر
            showStyledSnackBar(context, message: e.toString(), isError: true);
          }
        },
      );
    }
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
//  ✅ الجزء الذي تم تعديله ✅
// =========================================================================
class actionsForAdmins extends StatefulWidget {
  final int privilege;
  final String date;
  final int aukaf;
  final int test_id;
  final Function(Profile profile) methodFromGrandPa;

  const actionsForAdmins({
    super.key,
    required this.privilege,
    required this.date,
    required this.aukaf,
    required this.test_id,
    required this.methodFromGrandPa,
  });

  @override
  State<actionsForAdmins> createState() => _actionsForAdminsState();
}

class _actionsForAdminsState extends State<actionsForAdmins> {
  // 🗑️ تم حذف كل المتغيرات والدوال المتعلقة بالـ AlertDialog
  // لأن منطقها انتقل بالكامل إلى صفحة AddTestsScreen

  @override
  Widget build(BuildContext context) {
    if (widget.privilege != 3) {
      return const SizedBox.shrink();
    }

    final bool canCreateAwqafTest =
        DateTime.now().isAfter(DateTime.parse(widget.date)) &&
            widget.aukaf == 0;

    return Column(
      children: [
        _buildAdminButton(
          text: 'حذف السبر',
          color: const Color.fromARGB(255, 169, 62, 62),
          onPressed: () async {
            // عرض لودر مؤقت
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: ModernLoader()),
            );

            try {
              final profile = Provider.of<Profile>(context, listen: false);
              // استدعاء الدالة بدون context
              await profile.delete_test(widget.test_id);

              if (!mounted) return;

              Navigator.pop(context); // إغلاق اللودر
              showStyledSnackBar(context, message: 'تم الحذف بنجاح');

              // استدعاء الدالة لتحديث الواجهة السابقة
              widget.methodFromGrandPa.call(profile);
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(context); // إغلاق اللودر
              showStyledSnackBar(context, message: e.toString(), isError: true);
            }
          },
        ),
        if (canCreateAwqafTest) ...[
          const SizedBox(height: 10),
          _buildAdminButton(
            text: 'إنشاء سبر أوقاف للناجحين',
            color: Colors.green,
            onPressed: () {
              // ✨ التغيير الرئيسي هنا ✨
              // الانتقال إلى صفحة الإضافة مع تمرير المعرّف
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTestsScreen(
                    originalTestId: widget.test_id,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAdminButton(
      {required String text,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: sizeConfig.defaultSize! * 24,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            side: BorderSide.none,
            shape: const StadiumBorder()),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
