
import 'package:flutter/material.dart';

class notesReportCard extends StatelessWidget {
  Map<String, dynamic>? one_note;
  notesReportCard({required this.one_note});
  @override
  Widget build(BuildContext context) {
    try {
          return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration:         const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35)),
          color: Color.fromARGB(255, 253, 251, 251),
          boxShadow: [
            BoxShadow(color:Color.fromARGB(255, 255, 67, 5), spreadRadius:0.5 ,blurRadius: 4 ,offset: Offset(3, 3)),
          ],
        ),
        // color: Colors.black54,
        width: 300,
        height: 190,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  ' الملاحظة: ${one_note!['note']} ',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
               const SizedBox(height: 20),
                               Text(
                  ' النقاط المخصومة: ${one_note!['lost_point']} ',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
               ],
            ),
          ),
        ),
      ),
    );
  
    } catch (e) {
      return Text("لا يوجد ملاحظات لعرضها ");
    }
}
}
