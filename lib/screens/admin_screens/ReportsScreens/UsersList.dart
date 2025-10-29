import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/NotesReport/notesReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/activityReport/activityReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/hadithReport/hadithReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/quraanReport/quraanReportRoot.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class usersList extends StatelessWidget {
  final dynamic reportForUser;
  final int user_id_from_api;

  const usersList({
    super.key,
    required this.reportForUser,
    required this.user_id_from_api,
  });

  //  Helper method to show a styled SnackBar for errors
  void _showErrorSnackBar(BuildContext context, String message) {
                                                      showStyledSnackBar(context,
                                                      
          message:    message, isError:  true);


  }

  //  Helper method to handle navigation logic
  void _navigateToReport(
    BuildContext context, {
    required dynamic reportData,
    required String errorMessage,
    required Widget screen,
  }) {
    if (reportData == null) {
      _showErrorSnackBar(context, errorMessage);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  //  Helper method to process menu item selection
  void _handleMenuSelection(BuildContext context, int value) {
    switch (value) {
      case 1:
        // البيانات الآن عبارة عن Map وليست List
        final quraanReportData = reportForUser['ended_quraan_this_course'];
        
        // التحقق من أن البيانات ليست null وأن إحدى القائمتين على الأقل تحتوي على عناصر
        bool hasGhaibanData = quraanReportData != null && quraanReportData['ghaiban'] != null && quraanReportData['ghaiban'].isNotEmpty;
        bool hasNazaranData = quraanReportData != null && quraanReportData['nazaran'] != null && quraanReportData['nazaran'].isNotEmpty;

        if (!hasGhaibanData && !hasNazaranData) {
          _showErrorSnackBar(context, 'لا يوجد إنجاز قرآن مضاف لهذا الطالب');
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => QuraanReports(
              // إرسال الـ Map بأكمله
              ended_quraan_this_course: quraanReportData,
            )),
          );
        }
        break;
      case 2:
        _navigateToReport(
          context,
          reportData: reportForUser['ended_hadith_this_course'],
          errorMessage: 'لا يوجد انجاز حديث مضاف لهذا الطالب',
          screen: hadithReports(
            ended_hadith_this_course: reportForUser['ended_hadith_this_course'],
          ),
        );
        break;
      case 3:
        _navigateToReport(
          context,
          reportData: reportForUser['activities_this_course'],
          errorMessage: 'لا يوجد نشاطات مضافة لهذا الطالب',
          screen: activityReports(
            ended_activity_this_course: reportForUser['activities_this_course'],
          ),
        );
        break;
      case 4:
        _navigateToReport(
          context,
          reportData: reportForUser['notes'],
          errorMessage: 'لا يوجد ملاحظات مضافة لهذا الطالب',
          screen: notesReports(
            notes_in_this_course: reportForUser['notes'],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);

    // ✅ Determine user's permission to view notes report
    final bool canViewNotes = (user_id_from_api == user.id ||
        reportForUser['teacher_id'] == user.id ||
        user.privilege == 3);
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 4,
    shadowColor: Colors.teal.withOpacity(0.2),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade50,
            Colors.green.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: const Image(
                image: AssetImage('images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الاسم : ${reportForUser['user_name']}",
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "الأستاذ : ${reportForUser['teacher_id']}",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Popup Menu
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_horiz_outlined, color: Colors.teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (context) {
              final List<PopupMenuEntry<int>> menuItems = [
                const PopupMenuItem(
                    value: 1,
                    child: Text("تقرير القرآن",
                        style: TextStyle(fontWeight: FontWeight.w500))),
                const PopupMenuItem(
                    value: 2,
                    child: Text("تقرير الحديث",
                        style: TextStyle(fontWeight: FontWeight.w500))),
                const PopupMenuItem(
                    value: 3,
                    child: Text("تقرير النشاطات",
                        style: TextStyle(fontWeight: FontWeight.w500))),
              ];
              if (canViewNotes) {
                menuItems.add(
                  const PopupMenuItem(
                      value: 4,
                      child: Text("تقرير الإنذارات",
                          style: TextStyle(fontWeight: FontWeight.w500))),
                );
              }
              return menuItems;
            },
          ),
        ],
      ),
    ),
  ),
);
  }
}