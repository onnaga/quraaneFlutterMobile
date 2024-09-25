


import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Resetpassword extends StatelessWidget {
  
  String oldPassword ="";
  String newPassword='';
  
  String? passwordValidator (String? value) {
    if (value == '') {
      return 'أدخل كلمة المرور';
    }
  }
GlobalKey<FormState> formKey = GlobalKey<FormState>();

   Resetpassword({
   
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    return Scaffold(

      appBar:
       AppBar(title: Text('إعادة تعيين كلمة المرور',style: TextStyle(color: Colors.white),),backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.only(top: 150 ,left:30,right: 30 ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  validator:passwordValidator,
                  style:  TextStyle(fontSize:sizeConfig.defaultSize!*1.4),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.password_outlined),
                    iconColor: Colors.green,
                    labelText: 'كلمة السر القديمة',
                    labelStyle:  TextStyle(fontSize:sizeConfig.defaultSize!*1.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                  onSaved: (String? value) {oldPassword = value!;},
                  
                ),
                SizedBox(height: sizeConfig.defaultSize!*2),
                TextFormField(
                  style:TextStyle(fontSize:sizeConfig.defaultSize!*1.4),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.password),
                    iconColor: Colors.green,
                    labelText: ' كلمة السر الجديدة',
                    labelStyle: TextStyle(fontSize:sizeConfig.defaultSize!*1.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                  onSaved: (String? value) {newPassword = value!;},
                  validator: passwordValidator,
                ),
                SizedBox(height:sizeConfig.defaultSize!*5),
                
       Material(
        elevation: 5,
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
            minWidth: sizeConfig.defaultSize!*15,
            onPressed: () {
              
               FormState form = formKey.currentState as FormState;
              if (!form.validate()) {
                return;
              }
              form.save();
              User user = Provider.of<User>(context,listen: false);
              user.resetPassword(context,oldPassword,newPassword).then((auth) {
                if (auth) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم تحديث كلمة المرور'),
            backgroundColor: Colors.green,
          ));
                } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('يوجد مشكلة من تحديث كلمة المرور    '),
            backgroundColor: const Color.fromARGB(255, 175, 79, 76),
          ));
                }
              });
            }
            
,
            child:  Text("تغيير كلمة المرور" ,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: sizeConfig.defaultSize!*1.5
                )
            )
         
        )
    ),
            
                SizedBox(height: sizeConfig.defaultSize!*5),
          
            ],
            ),
          ),
        ),
      )
    
    
    ) ;
    
    
    
    
    
    
    }

      void submit (BuildContext context) {
              
               FormState form = formKey.currentState as FormState;
              if (!form.validate()) {
                return;
              }
              form.save();
              User user = Provider.of<User>(context,listen: false);
              user.resetPassword(context,oldPassword,newPassword).then((auth) {
                if (auth) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم تحديث كلمة المرور'),
            backgroundColor: Color.fromARGB(255, 147, 175, 76),
          ));
                } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('يوجد مشكلة من تحديث كلمة المرور    '),
            backgroundColor: const Color.fromARGB(255, 175, 79, 76),
          ));
                }
              });
            }
            
}
