
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';




class AddAdminsScreen extends StatefulWidget {
  const AddAdminsScreen({super.key});

  @override
  State<AddAdminsScreen> createState() => _AddAdminsScreenState();
}

class _AddAdminsScreenState extends State<AddAdminsScreen> {
  String? username;
  String? password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  

  String privilegeValue = "3";
  static List<String> items = [
    'استاذ مسمع',
    'استاذ ومدير',
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            // -- Form Fields
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(19),
                                bottomRight: Radius.circular(19))),
                        label: Text('الاسم الثلاثي'),
                        prefixIcon: Icon(Icons.person,color:  Color.fromARGB(255, 0, 0, 0),)),
                  
                        onSaved: (String? value) {username = value;},
                        validator: usernameValidator,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(19),
                                bottomRight: Radius.circular(19))),
                        label: Text('كلمة المرور'),
                        prefixIcon: Icon(Icons.password,color:  Colors.black)),
                  
                        onSaved: (String? value) {password = value;},
                        validator: passwordValidator,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    iconEnabledColor:  Colors.black,
                    iconSize: 44,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(19),
                        bottomRight: Radius.circular(19)),
                    autofocus: true,
                    alignment: AlignmentDirectional.bottomEnd,
                    value: items[1],
                    hint: Text('Select an option'),
                    onChanged:(String? value){
                        privilegeValue = value == 'استاذ مسمع' ? "2" : "3";
                    },
                    validator: PrivilegeValidator,
                    items: items
                        .map<DropdownMenuItem<String>>((String dropdownvalue) {
                      return DropdownMenuItem<String>(
                        value: dropdownvalue,
                        child: Center(
                          child: Text(dropdownvalue),
                        ),
                      );
                    }).toList(),
                  ),

// -- Form Submit Button,
                  const SizedBox(height: 20),
                   submitFormButton1(submit: submit),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? PrivilegeValidator(String? value) {
    if (value != "استاذ مسمع" && value != "استاذ ومدير") {
      return 'اختر نوع التصريح للأستاذ , يوجود مشكلة';
    }
  }

  String? usernameValidator (String? value) {
    if (value == '') {
      return 'أدخل اسم المستخدم';
    }
  }

  String? passwordValidator (String? value) {
    if (value == '') {
      return 'أدخل كلمة المرور';
    }
  }

  void submit () {
    FormState form = formKey.currentState as FormState;
    if (!form.validate()) {
      return;
    }
    form.save();
   
    User user = Provider.of<User>(context,listen: false);
      user.add_admin(context,username as String ,password as String , privilegeValue)
          .then((auth){
        if (auth) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.green,
                        content: Text(
                          ' تم إضافة الاستاذ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
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


  

class submitFormButton1 extends StatelessWidget {
   final void Function()  submit ;
  const submitFormButton1({
    super.key,
    required this.submit
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          this.submit();
        },
        
        
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            side: BorderSide.none,
            shape: const StadiumBorder()),
        child: const Text('إضافة',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
