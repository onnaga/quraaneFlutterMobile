


import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class logOutButton extends StatelessWidget {
  final user ;

  const logOutButton({
    required this.user ,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    return SizedBox(
      width: sizeConfig.defaultSize!*3,
      child: GestureDetector(
        onTap: () async{
          
              
       SharedPreferences preferences = await SharedPreferences.getInstance();
       preferences.remove('token');
          user.login_via_token(context).then((auth) {
            if (!auth) {
                Navigator.of(context).popAndPushNamed('login');
             
            } else {
              WidgetsBinding.instance.addPostFrameCallback((d) {
                Navigator.of(context).popAndPushNamed('redirect');
              });
            }
          });
        },
        child: Center(child: const Icon(Icons.logout,color: Color.fromARGB(255, 0, 0, 0),),),),
    );
  }
}

