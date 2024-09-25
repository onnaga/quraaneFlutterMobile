import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/ActCard.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/AddHadith.dart';

import 'dart:developer';


import 'package:masjed/data/objects.dart';

import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class LatestActivity extends StatefulWidget {
    final int  userId ;  

  const LatestActivity({super.key , required this.userId});

  @override
  State<LatestActivity> createState() => _LatestActivityState();
}

class _LatestActivityState extends State<LatestActivity> {
  int NumberOfHadith = 1;
  int NumberOfHomeworks = 1;
  @override
  void initState() {
    int NumberOfHadith = 1;
    int NumberOfHomeworks = 1;
    super.initState();
  }

  var ActivityCard = ActCard();
  
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<activitiesToSend> theActivitisToSendToProfile = [];

  

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        NotificationListener<activitiesToSend>(
          onNotification: (activitiesToSend notification) {
            print(notification.toJson().toString());

            theActivitisToSendToProfile.add(notification);
            'You have pressed button ${notification} times.';

            return true;
          },
          child: Expanded(
            child: ListView.builder(
              itemCount: NumberOfHadith,
              itemBuilder: (context, index) {
                //when the element is the last element in the list
                if (NumberOfHadith - index == 1) {
                  ActivityCard = ActCard();
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
                      ActivityCard,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (ActivityCard.submit(context)) {
  
                                  theActivitisToSendToProfile;
                                  NumberOfHadith++;
                                }

                              });
                            },
                            icon: Icon(Icons.add_circle_rounded),
                          ),
                          
                          submitFormButton(submit: submit),
                          IconButton(
                            onPressed: () {
                              
                              setState(() {
                                if ( NumberOfHadith == 1) {
                                  NumberOfHadith;
                                    theActivitisToSendToProfile;
                                }else{
 NumberOfHadith--;
   theActivitisToSendToProfile.removeLast();
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
                  if (theActivitisToSendToProfile.length - 1 < index) {
                    return SizedBox();
                  }

                  return ActCard.completedForm(activityForForm:  theActivitisToSendToProfile[index]);
                  

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
   
  //   List<Map<String, dynamic>> secondArray = [];

// List<Map<String, dynamic>> firstArray = [];
//     theActivitisToSendToProfile.forEach((item) {
//       firstArray.add(item.toJson());
//     });
    print(widget.userId);
    print('/////////////////////////////////////////////////////////////////');
    print(theActivitisToSendToProfile);
    
    user.add_latest_activity(
        context, widget.userId, theActivitisToSendToProfile).then((auth) {
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



