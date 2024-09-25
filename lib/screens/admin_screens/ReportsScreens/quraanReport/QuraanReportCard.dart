
                // "num": 1,
                // "from": 1,
                // "to": 20225,
                // "mark": 100,
                // "point": 50,
                // "number_of_repetitions": 1
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';

class QuraanReportCard extends StatelessWidget {
  Map<String, dynamic>? one_quraan_achive;
  QuraanReportCard({required this.one_quraan_achive});
  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration:         const BoxDecoration(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' اسم السورة:  ${Quraansoarmanage.soarList[one_quraan_achive?['num']]} \n \n تقييم تسميع السورة:  ${one_quraan_achive?['mark']} \n\n النقاط المكتسبة من السورة:  ${one_quraan_achive?['point']}  ',
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      ' من الآية: ${one_quraan_achive?['from']} \n\n : إلى الآية ${one_quraan_achive?['to']}\n\n  عدد مرات التسميع المقبول : ${one_quraan_achive?['number_of_repetitions']}  ',
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
