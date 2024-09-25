import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/NotesReport/notesReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/activityReport/activityReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/hadithReport/hadithReportsRoot.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/quraanReport/quraanReportRoot.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class usersList extends StatelessWidget {
  dynamic  reportForUser;
  final int  user_id_from_api; 
  usersList({required this.reportForUser ,required this.user_id_from_api });
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
     
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const Image(image: AssetImage('images/avatar.png'))),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                " الاسم : ${reportForUser!['user_name']} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                " الاستاذ : ${reportForUser!['teacher_id']} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Spacer(flex: 1),
           (user_id_from_api==user.id ||reportForUser['teacher_id']==user.username ||user.privilege==3)?
          ////////////////////////////////////if/////////////////////////////////////
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz_outlined),
            onSelected: (value) {
              
              switch (value) {
                
                case 1:
                
                  if (reportForUser!['ended_quraan_this_course'] == null) {
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد إنجاز قرآن مضاف لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuraanReports(
                          ended_quraan_this_course:
                              reportForUser!['ended_quraan_this_course']),
                    ),
                  );
                  }
                  break;
                case 2:
                  if (reportForUser!['ended_hadith_this_course'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد انجاز حديث مضاف لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => hadithReports(
                          ended_hadith_this_course:
                              reportForUser!['ended_hadith_this_course']),
                    ),
                  );}
                  break;
                case 3:
                  if (reportForUser!['activitis_this_course'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد نشاطات مضافة لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => activityReports(
                          ended_activity_this_course:
                              reportForUser!['activitis_this_course']),
                    ),
                  );}
                  break;
                case 4:
                
                  if (reportForUser!['notes'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد ملاحظات مضافة لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => notesReports(
                            notes_in_this_course: reportForUser!['notes']),
                      ),
                    );
                  }
                  break;
                default:
                  print('inside default on swich in userList.dartfile line 80');
              }
            },
            itemBuilder: (BuildContext) {
              return  const [
                PopupMenuItem(
                  child: Text("تقرير القرآن"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('تقرير الحديث'),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('تقرير النشاطات'),
                  value: 3,
                ),
                  PopupMenuItem(
                  child: Text('تقرير الملاحظات'),
                  value: 4,
                )
              ];
            },
          ):      
          
          ////////////////////////////////////////////else////////////////////////////
              PopupMenuButton(
            icon: const Icon(Icons.more_horiz_outlined),
            onSelected: (value) {
              switch (value) {
                case 1:
                  if (reportForUser!['ended_quraan_this_course'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد إنجاز قرآن مضاف لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuraanReports(
                          ended_quraan_this_course:
                              reportForUser!['ended_quraan_this_course']),
                    ),
                  );
                  }
                  break;
                case 2:
                  if (reportForUser!['ended_hadith_this_course'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد انجاز حديث مضاف لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => hadithReports(
                          ended_hadith_this_course:
                              reportForUser!['ended_hadith_this_course']),
                    ),
                  );}
                  break;
                case 3:
                  if (reportForUser!['activitis_this_course'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'لا يوجد نشاطات مضافة لهذا الطالب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => activityReports(
                          ended_activity_this_course:
                              reportForUser!['activitis_this_course']),
                    ),
                  );}
                  break;
  default:
                  print('inside default on swich in userList.dartfile line 53');
              }
            },
            itemBuilder: (BuildContext) {
              return  const [
                PopupMenuItem(
                  child: Text("تقرير القرآن"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('تقرير الحديث'),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('تقرير النشاطات'),
                  value: 3,
                ),
       
              ];
            },
          )
        ],
      ),
    );
  }
}
