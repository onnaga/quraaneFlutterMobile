import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/quraanReport/QuraanReportCard.dart';

class QuraanReports extends StatelessWidget {
  List<dynamic>? ended_quraan_this_course;
  QuraanReports({required this.ended_quraan_this_course});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: ended_quraan_this_course!.length,
        itemBuilder: (context, index) {
          return QuraanReportCard(
            one_quraan_achive: ended_quraan_this_course![ended_quraan_this_course!.length-index-1],
          );
        },
      ),
    );
  }
}
