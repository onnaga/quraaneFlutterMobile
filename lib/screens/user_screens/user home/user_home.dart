import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/logoutButton.dart';
import 'package:masjed/core/widgets/setting/settingRoot.dart';

import 'package:masjed/core/widgets/setting/resetPassword.dart';
import 'package:masjed/screens/user_screens/user%20home/userReport.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';


class UserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.vertical,
      children: [
        ProfileScreen(),
        UserReport(),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    
    return Consumer<User>(
      
      builder: (context, user, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical:sizeConfig.defaultSize!*2, horizontal: sizeConfig.defaultSize!*0.5),
          child: Column(
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  logOutButton(user: user,),
                  GestureDetector(
                    child: Icon(Icons.settings),
                    onTap: ()async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: 
                (context) => 
                (settingRoot()),),);                          
  
                setState(() {
                  
                });
                  },
                  ),
                



 
                ],
              ),

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
                                      child: (user.image == null)
                                          ? Image.asset('images/avatar.png',
                                              fit: BoxFit.fill)
                                          : Image.file(user.image as File,
                                              fit: BoxFit.fill))
                                ]);
                          });
                    },
                    child: SizedBox(
                      width: sizeConfig.defaultSize!*18,
                      height:sizeConfig.defaultSize!*18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: (user.image == null)
                            ? Image.asset('images/avatar.png', fit: BoxFit.fill)
                            : Image.file(user.image as File, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: TextButton(
                  //     onPressed: () async {
                  //       picker
                  //           .pickImage(
                  //         source: ImageSource.gallery,
                  //         imageQuality: 100,
                  //       )
                  //           .then((file) {
                  //         if (file == null) {
                  //           return;
                  //         }
                  //         user.update_image(File(file.path));
                  //       });
                  //     },
                  //     child: Container(
                  //       width: sizeConfig.defaultSize!*3.5,
                  //       height: sizeConfig.defaultSize!*3.5,
                  //       decoration: BoxDecoration(
                  //           color: Colors.green,
                  //           borderRadius: BorderRadius.circular(100)),
                  //       child:  Icon(
                  //         Icons.camera_alt,
                  //         color: Colors.white,
                  //         size: sizeConfig.defaultSize!*2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                
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
                        child: Text(user.username as String),
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
                        child: Text(user.details?['phone'] as String),
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
                        child: Text((user.details?['age'] as int).toString()),
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
                          child: Text(user.teache_name as String ),
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
      },
    );
  }
}


// class ExitAlert extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       elevation: 24.0,
//       content: const Text('هل تريد بالفعل تسجيل الخروج؟'),
//       actions: [
//         TextButton(
//           child: const Text('كلا'),
//           onPressed: (){Navigator.of(context, rootNavigator: true).pop(this);},
//         ),
//         TextButton(
//           child: const Text('نعم'),
//           onPressed: (){},
//         ),
//       ],
//     );
//   }
// }