
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/logoutButton.dart';
import 'package:masjed/screens/login.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitToTakeTeacher extends StatelessWidget {
  final user ;
  const WaitToTakeTeacher({ this.user,super.key});
  
  @override

  Widget build(BuildContext context) {
        debugger();
    return 

    Scaffold(
    body:    Column(
      children:[
       Center(child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset('images/penalty.png'),
                ),),
                const SizedBox(height: 10,),
                const Text(' لا يمكنك القيام بشيء إذا لم يستلمك استاذ تواصل مع استاذ وحاول مجددا',style: TextStyle(fontSize: 30),),
                 const SizedBox(height: 10,),
                 ElevatedButton(
          onPressed: ()async {
                       
       SharedPreferences preferences = await SharedPreferences.getInstance();
       preferences.remove('token');
                  //           showDialog(
                  // context: context,
                  // barrierDismissible: true,
                  // builder: (context) => ExitAlert()
                  //         );
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
          child: const Text('Go back!'),
        ),
      ]

  
      ),);
  }

}

