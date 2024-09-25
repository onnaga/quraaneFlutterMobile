import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Initialize extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InitializeState();
}


class InitializeState extends State<Initialize> {

  @override
  void initState() {
    super.initState();
    User user = Provider.of<User>(context,listen: false);
    
    user.login_via_token(context)
        .then((auth){
          
      if (!auth) {WidgetsBinding.instance.addPostFrameCallback((d){Navigator.of(context).popAndPushNamed('login');});}
      else {WidgetsBinding.instance.addPostFrameCallback((d){Navigator.of(context).popAndPushNamed('redirect');});}
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Loading(),
    );
  }

}



class Loading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoadingState();
}


class LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(seconds: 4) , vsync: this);
    animation = Tween<double>(begin: 0, end: 3.1415926535897932).animate(controller)
      ..addListener(() {setState(() {});})
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        }
      });
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Transform.rotate(
              angle: animation.value,
              child: SizedBox(
                width: 175,
                height: 175,
                child: Image.asset('images/green_pattern.png'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 25),
              child: Text("الرجاء الانتظار"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

}