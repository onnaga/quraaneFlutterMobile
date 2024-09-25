import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/AddHadith.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/AddHadithHomework.dart';

import 'dart:developer';

import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/data/objects.dart';

import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class LatestHadith extends StatefulWidget {
    final int  userId ;  

  const LatestHadith({super.key , required this.userId});

  @override
  State<LatestHadith> createState() => _LatestHadithState();
}

class _LatestHadithState extends State<LatestHadith> {
  int NumberOfHadith = 1;
  int NumberOfHomeworks = 1;
  @override
  void initState() {
    int NumberOfHadith = 1;
    int NumberOfHomeworks = 1;
    super.initState();
  }

  var hadith = AddHadith();
  var Hadithhomework = AddHadithHomework();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<endedSurahToSend> theAhadithToSendToProfile = [];

  List<homeworkSurahToSend> theAhadithHomewroksToSendToProfile = [];

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        NotificationListener<endedSurahToSend>(
          onNotification: (endedSurahToSend notification) {
            print(notification.toJson().toString());

            theAhadithToSendToProfile.add(notification);
            'You have pressed button ${notification} times.';

            return true;
          },
          child: Expanded(
            child: ListView.builder(
              itemCount: NumberOfHadith,
              itemBuilder: (context, index) {
                //when the element is the last element in the list
                if (NumberOfHadith - index == 1) {
                  hadith = AddHadith();
                  return Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'البيانات الموجودة في هذا الحقل لن تضاف',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      hadith,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (hadith.submit(context)) {
                                  theAhadithToSendToProfile;
                                  NumberOfHadith++;
                                }

                              });
                            },
                            icon: Icon(Icons.add_circle_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              
                              setState(() {
                                if ( NumberOfHadith == 1) {
                                  NumberOfHadith;
                                    theAhadithToSendToProfile;
                                }else{
 NumberOfHadith--;
   theAhadithToSendToProfile.removeLast();
                                }
                               
                            
                              
                              });
                            },
                            icon: Icon(Icons.minimize_rounded),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                //when the element is not the last element
                else {
                  if (theAhadithToSendToProfile.length - 1 < index) {
                    return SizedBox();
                  }

                  return AddHadith.completedForm(
                      hadithForForm: theAhadithToSendToProfile[index]);
                }
              },
            ),
          ),
        ),
        NotificationListener<homeworkSurahToSend>(
          onNotification: (homeworkSurahToSend notification) {
            print(notification.toJson().toString());

            theAhadithHomewroksToSendToProfile.add(notification);

            return true;
          },
          child: Expanded(
            child: ListView.builder(
              itemCount: NumberOfHomeworks,
              itemBuilder: (context, index) {
                //when the element is the last element in the list
                if (NumberOfHomeworks - index == 1) {
                  Hadithhomework = AddHadithHomework();
                  return Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'البيانات الموجودة في هذا الحقل لن تضاف',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      Hadithhomework,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (Hadithhomework.submit(context)) {
                                  theAhadithHomewroksToSendToProfile;
                                  NumberOfHomeworks++;
                                }
                              });
                            },
                            icon: Icon(Icons.add_circle_rounded),
                          ),
                          submitFormButton(submit: submit),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (NumberOfHomeworks == 1){
                                   NumberOfHomeworks;
                                }else{
 NumberOfHomeworks--;
  theAhadithHomewroksToSendToProfile.removeLast();
                                }

                               
                              });
                            },
                            icon: Icon(Icons.minimize_rounded),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                //when the element is not the last element
                else {
                  return AddHadithHomework.completedForm(
                      homeworkForForm: theAhadithHomewroksToSendToProfile[index]);
                }
              },
            ),
          ),
        ),
      ],
    );
  
  
  
    
    
    
    
    }






  void submit() {

    User user = Provider.of<User>(context, listen: false);
 
////////////////////the inner data is not in json ////////////////////////
  //  List<Map<String, dynamic>> firstArray = [];
  //   List<Map<String, dynamic>> secondArray = [];

    // theAhadithHomewroksToSendToProfile.forEach((item) {
    //   secondArray.add(item.toJson());
    // });

    // theAhadithToSendToProfile.forEach((item) {
    //   firstArray.add(item.toJson());
    // });


    
    print(widget.userId);
    print('/////////////////////////////////////////////////////////////////');
    print([theAhadithToSendToProfile, theAhadithHomewroksToSendToProfile]);
    user.add_latest_quraan_hadith(
        context, widget.userId, [theAhadithToSendToProfile, theAhadithHomewroksToSendToProfile],false).then((auth) {
      if (auth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1500),
            closeIconColor: Colors.white,
            showCloseIcon: true,
            backgroundColor: Colors.green,
            content: Text(
              ' تم إضافة البيانات',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1500),
            closeIconColor: Colors.white,
            showCloseIcon: true,
            backgroundColor: Colors.redAccent,
            content: Text(
              'توجد مشكلة في الإضافة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return auth;
    });
    
  }


}



