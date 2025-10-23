
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/providers/notification_provider.dart';
import 'package:masjed/screens/admin_screens/admin_app.dart';
import 'package:masjed/screens/redirect.dart';
import 'package:masjed/screens/super_admin_screens/select_daora_to_see_info.dart';
import 'package:masjed/screens/user_Ranking_screen/user_ranking.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjed/local.dart';
import 'package:masjed/state/user.dart';
import 'package:masjed/screens/initialize.dart';
import 'package:masjed/screens/login.dart';
import 'package:masjed/screens/register.dart';
import 'package:masjed/screens/user_screens/user_app.dart';
import 'package:masjed/providers/theme_provider.dart';



class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyApp(this.preferences, {super.key});

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        Provider<SharedPreferences>.value(value: preferences),

        ChangeNotifierProvider<Daorastate>(
          create: (_) => Daorastate()..loadDaoraId(),
        ),

        ChangeNotifierProvider<User>(
          create: (context) {
            User user = User();
            user.token = preferences.getString('token');
user.privilege = preferences.getInt('privilege');

            return user;
          },
        ),
ChangeNotifierProvider<NotificationProvider>(
  create: (_) => NotificationProvider(), // Fetch notifications on start
),
        ChangeNotifierProvider<Profile>(
          create: (context) => Profile(),
        ),

        /// Theme provider
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
    ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'مسجدي',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: localizationsDelegates,
            supportedLocales: supportedLocales,
            routes: {
              '/': (context) => const Initialize(),
              'login': (context) => const Login(),
              'register': (context) => const Register(),
              'redirect': (context) => const Redirect(),
              'user': (context) => UserApp(),
              'admin': (context) => AdminApp(),
              'super_admin': (context) => const SelectDaoraToSeeInfo(),
              'user_ranking': (context) => const UserRanking(),

            },
          );
        },
      ),
    );
  }
}

