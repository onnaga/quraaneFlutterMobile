import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/user.dart';

class Redirect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context,listen: false);
    String route = switch (user.privilege) {
    1 =>'user',
    2 =>'admin' ,
    3 =>'admin' ,
      _ => throw Exception()
    };
    WidgetsBinding.instance.addPostFrameCallback((d){
      Navigator.of(context).popAndPushNamed(route);
    });
    return const SizedBox();
  }
}