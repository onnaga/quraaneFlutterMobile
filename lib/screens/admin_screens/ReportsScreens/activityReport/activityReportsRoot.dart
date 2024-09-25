import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/activityReport/activityReportCard.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/hadithReport/HadithReportCard.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/quraanReport/QuraanReportCard.dart';

class activityReports extends StatelessWidget {
  List<dynamic>? ended_activity_this_course;
  activityReports({required this.ended_activity_this_course});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: ended_activity_this_course!.length,
        itemBuilder: (context, index) {
          return activityReportCard(one_activity_achive:ended_activity_this_course![ended_activity_this_course!.length-index-1],);
        },
      ),
    );
  }
}
