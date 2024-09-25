





import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class changeDetails extends StatelessWidget {
  
  late int age ;
  String phone_number="";
  
  String? phone_numberValidator (String? value) {
    if (value == '') {
      return 'أدخل كلمة المرور';
    }
  }
  
  String? age_validator (int? value) {
    if (value == null){return 'ادخل العمر';}
    return null;
  }
GlobalKey<FormState> formKey = GlobalKey<FormState>();

   changeDetails({
   
    super.key,
  });


  @override
  Widget build(BuildContext context) {
  User user = Provider.of<User>(context,listen: false);
    sizeConfig().init(context);
    return Scaffold(

      appBar:
       AppBar(title: Text('تغيير التفاصيل',style: TextStyle(color: Colors.white),),backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.only(top: 150 ,left:30,right: 30 ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: user.details?['phone'],
                  validator:phone_numberValidator,
                  style:  TextStyle(fontSize:sizeConfig.defaultSize!*1.4),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.phone_android_rounded),
                    iconColor: Colors.green,
                    labelText: 'رقم الهاتف',
                    labelStyle:  TextStyle(fontSize:sizeConfig.defaultSize!*1.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                  onSaved: (String? value) {phone_number = value!;},
                  
                ),
                SizedBox(height: sizeConfig.defaultSize!*2),
                     DropdownButtonFormField(
                      
                        onSaved: (value){age = value!;},
                        validator: age_validator,
                        onChanged: (i){},
                        borderRadius: BorderRadius.circular(15),
                        menuMaxHeight: 200,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(45.0),
                            ),
                            label: Text('اختر العمر'), prefixIcon: Icon(Icons.calendar_today)
                        ),
                        items: List.generate(70, (i){
                          return DropdownMenuItem(
                            value: i+1,
                            child: Center(child: Text(((i+1).toString())),),
                          );
                        })
                    ),
 SizedBox(height:sizeConfig.defaultSize!*5),
                
       Material(
        elevation: 5,
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
            minWidth: sizeConfig.defaultSize!*15,
            onPressed: () {
              submit(context);
              },
            child:  Text("تغيير " ,
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
              user.update_details(context,age,phone_number).then((auth) {
                if (auth) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم تحديث '),
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
