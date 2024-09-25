import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/AddAdminsScreen.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/AddHomework.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/AddSora.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class Latestquraan extends StatefulWidget {
  final int userId;
  const Latestquraan({super.key, required this.userId});

  @override
  State<Latestquraan> createState() => _LatestquraanState();
}

class _LatestquraanState extends State<Latestquraan> {
  int NumberOfSora = 1;
  int NumberOfHomeworks = 1;
  var sura = AddSora();
  var homework = AddHomework();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    int NumberOfSora = 1;
    int NumberOfHomeworks = 1;
    super.initState();
  }

  List<endedSurahToSend> theSoarToSendToProfile = [];

  List<homeworkSurahToSend> theHomewroksToSendToProfile = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NotificationListener<endedSurahToSend>(
          onNotification: (endedSurahToSend notification) {
            print(notification.toJson().toString());

            theSoarToSendToProfile.add(notification);
            'You have pressed button ${notification} times.';

            return true;
          },
          child: Expanded(
            child: ListView.builder(
              itemCount: NumberOfSora,
              itemBuilder: (context, index) {
                //when the element is the last element in the list
                if (NumberOfSora - index == 1) {
                  sura = AddSora();
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
                      sura,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (sura.submit(context)) {
                                  theSoarToSendToProfile;
                                  NumberOfSora++;
                                }

                              });
                            },
                            icon: Icon(Icons.add_circle_rounded),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if ( NumberOfSora == 1) {
                                  NumberOfSora;
                                    theSoarToSendToProfile;
                                }else{
 NumberOfSora--;
   theSoarToSendToProfile.removeLast();
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
                  if (theSoarToSendToProfile.length - 1 < index) {
                    return SizedBox();
                  }

                  return AddSora.completedForm(
                      sorahForForm: theSoarToSendToProfile[index]);
                }
              },
            ),
          ),
        ),
        NotificationListener<homeworkSurahToSend>(
          onNotification: (homeworkSurahToSend notification) {
            print(notification.toJson().toString());

            theHomewroksToSendToProfile.add(notification);

            return true;
          },
          child: Expanded(
            child: ListView.builder(
              itemCount: NumberOfHomeworks,
              itemBuilder: (context, index) {
                //when the element is the last element in the list
                if (NumberOfHomeworks - index == 1) {
                  homework = AddHomework();
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
                      homework,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (homework.submit(context)) {
                                  theHomewroksToSendToProfile;
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
  theHomewroksToSendToProfile.removeLast();
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
                  return AddHomework.completedForm(
                      homeworkForForm: theHomewroksToSendToProfile[index]);
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

    // theHomewroksToSendToProfile.forEach((item) {
    //   secondArray.add(item.toJson());
    // });

    // theSoarToSendToProfile.forEach((item) {
    //   firstArray.add(item.toJson());
    // });

    print(widget.userId);
    print('/////////////////////////////////////////////////////////////////');
    print([theSoarToSendToProfile, theHomewroksToSendToProfile]);
    user.add_latest_quraan_hadith(
        context, widget.userId, [theSoarToSendToProfile, theHomewroksToSendToProfile],true).then((auth) {
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
