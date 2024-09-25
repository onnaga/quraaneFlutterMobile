
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/teacherCard.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class WaitingStudentsPage extends StatefulWidget {
  const WaitingStudentsPage({super.key});
  @override
  State<WaitingStudentsPage> createState() => _WaitingStudentsPageState();
}
class _WaitingStudentsPageState extends State<WaitingStudentsPage> {
   
    bool logging = true ; 
   final firstScrollController = ScrollController();
   List<dynamic> DataFromApi = [];
  @override
  
  Widget build(BuildContext context) {
    debugger();
     User user = Provider.of<User>(context);
  return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    ListView.builder(
      
      controller: firstScrollController,
      itemCount: DataFromApi.length,

      itemBuilder: (context, index) {
        return 
         Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 252, 249, 249),
          boxShadow: [
            BoxShadow(color: Colors.green, spreadRadius: 0.1),
          ],
        ),
          height:130,
          child: WantingList(
            reportForUser: DataFromApi[index],
            user_id_from_api:  DataFromApi[index]['user_id'],
            parentUpdate:DownloadData ,
          ),
        );
      
      },
    ),
          
                       Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('تحميل البيانات',style: TextStyle(fontWeight: FontWeight.bold),),
                              
                              DownloaddataContextBTN(submit: DownloadData, logging: logging, profile: profile, sendedcontext: context),
          
                        SizedBox(height: 10,),
                        ],
                          ),
    
          ],
        );},);
        }

  Future<void> DownloadData( BuildContext context,Profile profile,) async {
    {
                              setState(() {
                                logging =true ;
                              });
                              await profile.show_users_without_teacher(context).then((then) {
                                if (then) {
                                 setState(() {
                                  debugger();
                                  if(profile.StudetntsWithoutTeachers!=null){DataFromApi = profile.StudetntsWithoutTeachers!;}
                                  else{DataFromApi =[];}
                                  print("object");
                                 });
                                }
        
                              },);
                                
                              
                             
                            }
  }




}

class WantingList extends StatelessWidget {
  dynamic  reportForUser;
  final int  user_id_from_api; 
  Future<void> Function(BuildContext context, Profile profile) parentUpdate;
  WantingList({required this.reportForUser ,required this.user_id_from_api ,required this.parentUpdate});
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
                " الاسم : ${reportForUser!['name']} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                " العمر : ${reportForUser!['age'].toString()} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
                           Text(
                " الرقم : ${reportForUser!['phone_number'].toString()} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
                           Text(
                " الأجزاء المحفوظة : ${reportForUser!['ended_quraan_in_aukaf'].toString()} ",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
          Spacer(flex: 3),   
          ElevatedButton(
                       onPressed: () {
                                      Profile profile = Provider.of<Profile>(context,listen: false);
                                      profile.take_student(context,user_id_from_api).then((thenValue){
                                        if (thenValue) {
                                          

                                          parentUpdate.call(context ,profile,);
}                                        else{
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('يوجد مشكلة تمنه من الوضول الى هذه الصفحة'),
                    backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                  ));
                                        }
                                      });
                       
                      
                       },
                       style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green,
                           side: BorderSide.none,
                           shape: const StadiumBorder()),
                             child: const Text(
                         'استلام الطالب',
                         style: TextStyle(color: Colors.white),
                       ),
                   )  
        ]
      ),
        
    );
  }
}
