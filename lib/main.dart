import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjed/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(await SharedPreferences.getInstance()));
}