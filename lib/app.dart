import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/admin_app.dart';
import 'package:masjed/screens/redirect.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjed/local.dart';
import 'package:masjed/state/user.dart';
import 'package:masjed/screens/initialize.dart';
import 'package:masjed/screens/login.dart';
import 'package:masjed/screens/register.dart';
import 'package:masjed/screens/user_screens/user_app.dart';


class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  MyApp(this.preferences,{super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SharedPreferences>(
          create: (context) => preferences,
        ),
        ChangeNotifierProvider<User>(
          create: (context) {
            User user = User();
            user.token = preferences.getString('token');
            return user;
          },
        ),
                ChangeNotifierProvider<Profile>(
          create: (context) {
            Profile profile = Profile();
            return profile;
          },
        ),
      ],
      child: MaterialApp(
         debugShowCheckedModeBanner: false,
        theme: ThemeData( ),
        title: 'masjed',
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        routes: {
          '/': (context) => Initialize(),
          'login': (context) => Login(),
          'register': (context) => Register(),
          'redirect': (context) => Redirect(),
          'user': (context) => UserApp(),
          'admin': (context) => AdminApp(),
        },
      ),
    );
  }

}