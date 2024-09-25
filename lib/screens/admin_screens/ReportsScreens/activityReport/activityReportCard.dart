
                // "name": "seam",
                // "mark": 100,
                // "point": 80,
                // "number_of_repetitions": 5
import 'package:flutter/material.dart';

class activityReportCard extends StatelessWidget {
  Map<String, dynamic>? one_activity_achive;
  activityReportCard({required this.one_activity_achive});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration:        const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(5)),
          color: Color.fromARGB(255, 253, 251, 251),
          boxShadow: [
            BoxShadow(color:Color.fromARGB(255, 65, 98, 65), spreadRadius:0.5 ,blurRadius: 8 ,offset: Offset(5, 5)),
          ],
        ),
        // color: Colors.black54,
        width: 300,
        height: 190,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  
                  children: [
                    Text(
                      ' اسم الإنجاز:  ${one_activity_achive?['name']} \n \n \n تقييم الإنجاز:  ${one_activity_achive?['mark']}  ',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 80),
                    Text(
                      ' النقاط المكتسبة من الإنجاز: ${one_activity_achive?['point']} \n \n \n  عدد مرات تكرار الإنجاز : ${one_activity_achive?['number_of_repetitions']}  ',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
             const SizedBox(height: 20),
   ],
          ),
        ),
      ),
    );
  }
}
