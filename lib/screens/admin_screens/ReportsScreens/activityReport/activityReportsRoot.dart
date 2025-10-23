import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/activityReport/activityReportCard.dart';

class activityReports extends StatelessWidget {
  List<dynamic>? ended_activity_this_course;
  activityReports({super.key, required this.ended_activity_this_course});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: ended_activity_this_course!.length,
        itemBuilder: (context, index) {
          return ActivityReportCard(oneActivityAchive:ended_activity_this_course![ended_activity_this_course!.length-index-1],);
        },
      ),
    );
  }
}
