import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/NotesReport/notesReportCard.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/activityReport/activityReportCard.dart';

class notesReports extends StatelessWidget {
  List<dynamic>? notes_in_this_course;
  notesReports({required this.notes_in_this_course});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notes_in_this_course!.length,
        itemBuilder: (context, index) {
          return notesReportCard(one_note:notes_in_this_course![notes_in_this_course!.length-index-1],);
        },
      ),
    );
  }
}
