import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/logoutButton.dart';
import 'package:masjed/core/widgets/setting/settingRoot.dart';

import 'package:masjed/core/widgets/setting/resetPassword.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/user_screens/user%20home/userReport.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';


class ShowuserhomeProfile extends StatelessWidget {
  final UserToShowProfile userToShowprofile ;
  const ShowuserhomeProfile({
    required this.userToShowprofile
  });

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          ProfileScreen(userToShowprofile: userToShowprofile,),
          UserReport.forProfile(user_id: userToShowprofile.id,),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final UserToShowProfile userToShowprofile ;
   ProfileScreen({
    required this.userToShowprofile
  });

  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    
        return Container(
          padding: EdgeInsets.symmetric(vertical:sizeConfig.defaultSize!*2, horizontal: sizeConfig.defaultSize!*0.5),
          child: Column(
            children: [
 
              /// -- IMAGE
              Stack(
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                          
                            return SimpleDialog(
                                contentPadding: EdgeInsets.zero,
                                
                                children: [
                                  
                                  SizedBox(
                                    
                                      height:sizeConfig.defaultSize!*40,
                                      child:  Image.asset('images/avatar.png',
                                              fit: BoxFit.fill)
                                  ),
                                ]);
                          });
                    },
                    child: SizedBox(
                      width: sizeConfig.defaultSize!*18,
                      height:sizeConfig.defaultSize!*18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child:Image.asset('images/avatar.png', fit: BoxFit.fill)
                           
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: sizeConfig.defaultSize!*3),
              const Divider(),
               SizedBox(height: sizeConfig.defaultSize!*1),

              /// -- MENU
              ListTile(
                leading:  Icon(
                  Icons.person,
                  color: Colors.green,
                  size: sizeConfig.defaultSize!*2.5,
                ),
                title: Row(
                  children: [
                     const  Expanded(
                      child: Center(
                        child: Text('الاسم :'),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(userToShowprofile.name as String),
                      ),
                      flex: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 3),

              ListTile(
                leading: Icon(
                  Icons.phone_android,
                  color: Colors.green,
                  size: sizeConfig.defaultSize!*2.5,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('الرقم :'),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(userToShowprofile.phone_number as String),
                      ),
                      flex: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 3),

              ListTile(
                leading:  Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                  size: sizeConfig.defaultSize!*2.5,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('العمر :'),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Center(
                        child: Text((userToShowprofile.age as int).toString()),
                      ),
                      flex: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 3),

              ListTile(
                leading:  Icon(
                  Icons.supervisor_account_rounded,
                  color: Colors.green,
                  size: sizeConfig.defaultSize!*2.5,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('المدرس :'),
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(userToShowprofile.teache_name as String ),
                        ),
                      ),
                      flex: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 3),
            ],
          ),
        );
      }
    
  }



