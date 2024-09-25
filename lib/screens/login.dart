import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/redirect.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/user.dart';


class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sizeConfig.defaultSize! , horizontal: sizeConfig.defaultSize! *2),
              child: Column(
                children: [
                   Padding(
                    padding: EdgeInsets.only(bottom: sizeConfig.defaultSize!*5),
                    child: SizedBox(
                      width: sizeConfig.defaultSize!*18,
                      height:sizeConfig.defaultSize!*18,
                      child: Image(image: AssetImage('images/icon.png') , fit: BoxFit.fill,),
                    ),
                  ),
                  LoginForm()
                ],
              ),
            )
        ),
      ),
    );
  }
}



class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String? username;
  String? password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Future<bool>? response;


  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: (response != null),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              style:  TextStyle(fontSize:sizeConfig.defaultSize!*1.4),
              decoration: InputDecoration(
                icon: const Icon(Icons.person),
                iconColor: Colors.green,
                labelText: 'اسم المستخدم',
                labelStyle:  TextStyle(fontSize:sizeConfig.defaultSize!*1.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(45.0),
                ),
              ),
              onSaved: (String? value) {username = value;},
              validator: usernameValidator,
            ),
            SizedBox(height: sizeConfig.defaultSize!*2),
            TextFormField(
              style:TextStyle(fontSize:sizeConfig.defaultSize!*1.4),
              decoration: InputDecoration(
                icon: const Icon(Icons.password),
                iconColor: Colors.green,
                labelText: 'كلمة المرور',
                labelStyle: TextStyle(fontSize:sizeConfig.defaultSize!*1.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(45.0),
                ),
              ),
              onSaved: (String? value) {password = value;},
              validator: passwordValidator,
            ),
            SizedBox(height:sizeConfig.defaultSize!*5),
            SubmitButton(submit, (response != null)),
            SizedBox(height: sizeConfig.defaultSize!*5),
            TextButton(
                child: Center(child: Text('انشاء حساب',style: TextStyle(color: Colors.green),),),
              onPressed: (){Navigator.pushNamed(context, 'register');},
            ),
          ],
        ),
      ),
    );
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
    setState(() {
      response = user.login(context,username as String ,password as String)
          .then((auth){
        if (auth) {WidgetsBinding.instance.addPostFrameCallback((d){
                              var nav = Navigator.of(context);
                              
                              nav.popAndPushNamed('redirect');
                            });}
        else {
          setState(() {
            response = null;
          });
        }
        return auth;
      });
    });
  }
}


class SubmitButton extends StatelessWidget {
  void Function() submit;
  bool logging;

  SubmitButton(this.submit,this.logging);

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 5,
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
            minWidth: sizeConfig.defaultSize!*15,
            onPressed: submit,
            child: (!logging) ?  Text("تسجيل دخول" ,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: sizeConfig.defaultSize!*1.5
                )
            )
                :
           SizedBox(
              width: sizeConfig.defaultSize!*1.5,
              height: sizeConfig.defaultSize!*1.5,
              child:const CircularProgressIndicator(color: Colors.white,strokeWidth: 2,),
            )
        )
    );
  }


}