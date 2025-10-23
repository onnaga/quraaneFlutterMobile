import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/hadithReport/HadithReportCard.dart';

class hadithReports extends StatelessWidget {
  final List<dynamic>? ended_hadith_this_course;
  const hadithReports({super.key, required this.ended_hadith_this_course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: ended_hadith_this_course!.length,
        itemBuilder: (context, index) {
          return HadithReportCard(
            oneHadithAchive: ended_hadith_this_course![ended_hadith_this_course!.length - index - 1],
          );
        },
      ),
    );
  }
}
