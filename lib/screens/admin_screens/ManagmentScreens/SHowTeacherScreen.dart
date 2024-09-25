
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/teacherCard.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  bool logging =true;

   List<dynamic> DataFromApi = [
  ];
  @override
  Widget build(BuildContext context) {
    
    return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    
    ListView.builder(
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: teacherCard(
            data: DataFromApi[index],
            updateScreen: downloadData,
          ),
        );
      },
    ),
                       Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('تحميل البيانات',style: TextStyle(fontWeight: FontWeight.bold),),
                             DownloaddataBTN(submit:  downloadData, logging: logging, profile: profile),
                             

                            SizedBox(height: 10,),
                        ],
                          ),
    
          ],
        );
        
        },
        
        );
    
    

  }
  
   downloadData(profile)async {
    debugger();
    setState(() {
      logging = false;
    });
                          await profile.get_teachers(context).then((then) {
                            if (then) {
                             setState(() {
                              
                              if(profile.TeachersList!=null){DataFromApi = profile.TeachersList!;}
                              else{DataFromApi =[];}
                              print("object");
                             });
                            }
    
                          logging = true;
                          },);
                            
                          
                         
                        }


}
