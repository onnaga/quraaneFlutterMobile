
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/teacherCard.dart';
import 'package:masjed/screens/admin_screens/testsScreens/TestCard.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class Showtests extends StatefulWidget {

  const Showtests({super.key});

  @override
  State<Showtests> createState() => _ShowtestsState();
}

class _ShowtestsState extends State<Showtests> {
  bool logging = true ; 
     List<TestData> DataFromApi = [
  ];
  final firstScrollController = ScrollController();
  

@override
  Widget build(BuildContext context) {
    return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    ListView.builder(
      controller: firstScrollController,
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: TestCard(
            data: DataFromApi[index],
            methodFromParent:downloadData ,
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
      logging = false ; 
    });
                          await profile.get_tests(context).then((then) {
                            if (then) {
                             setState(() {

                              if(profile.TestsList !=null){DataFromApi = profile.TestsList!;}
                              else{DataFromApi =[];}
                              print("object");
                             });
                            }
                            logging=true ;
                          },);
                            
                          
                         
                        }
}
