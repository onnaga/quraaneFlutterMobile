
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/teacherCard.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen> {
   bool logging =true;
  
   final firstScrollController = ScrollController();
   List<dynamic> DataFromApi = [];
  @override
  
  Widget build(BuildContext context) {
     User user = Provider.of<User>(context);
  return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    ListView.builder(
      
      controller: firstScrollController,
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return (DataFromApi[index]['user_id']==user.id ||DataFromApi[index]['teacher_id']==user.username )?
        ///////////////////////////if///////////////////////
         Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 180, 227, 139),
          boxShadow: [
            BoxShadow(color: Colors.green, spreadRadius: 0.1),
          ],
        ),
          height:70,
          child: usersList(
            reportForUser: DataFromApi[index],
            user_id_from_api:  DataFromApi[index]['user_id']
          ),
        ):
        ////////////////////////////else/////////////////////
         Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.green, spreadRadius: 0.1),
          ],
        ),
          height:70,
          child: usersList(
            reportForUser: DataFromApi[index],
            user_id_from_api: DataFromApi[index]['user_id'],
          ),
        );
      
      },
    ),
          
                       Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('تحميل البيانات',style: TextStyle(fontWeight: FontWeight.bold),),
                              DownloaddataBTN(submit: downloadData, logging: logging, profile: profile),

                              
 
                        SizedBox(height: 10,),
                        ],
                          ),
    
          ],
        );},);
        }


   downloadData(profile)async {
    setState(() {
      logging = false;
    });
                          await profile.show_reports(context).then((then) {
                            if (then) {
                             setState(() {
                              if(profile.ReportsList!=null){DataFromApi = profile.ReportsList!;}
                              else{DataFromApi =[];}
                              print("object");
                             });
                            }
                          logging = true ; 
                          }
                          
                          ,);
                            
                          
                         
                        }


}
