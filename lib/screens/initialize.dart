import 'package:flutter/material.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Initialize extends StatefulWidget {
  const Initialize({super.key});

  @override
  State<StatefulWidget> createState() => InitializeState();
}

class InitializeState extends State<Initialize> {

  @override
  void initState() {
    super.initState();
    
    // We call the initialization logic after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUser();
    });
  }

  void _initUser() async {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);

    // This loop is the key fix: it waits until the provider has a definitive connection status
    while (!connectivityProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
      
      
      
    }

    // Now we can safely get the connection status
    final isOnline = connectivityProvider.isOnline;
    final user = Provider.of<User>(context, listen: false);
    final daoraState = Provider.of<Daorastate>(context, listen: false);

    // print("Initialize decision: isOnline = $isOnline");

    // Online Path
    if (isOnline) {
      // print("Device is Online. Proceeding with login_via_token.");
      try {
        final userData = await user.login_via_token();
        if (mounted) {
          daoraState.setDaoraId(userData['daoraId']);
          Navigator.of(context).pushReplacementNamed('redirect');
        }
      } catch (e) {
        if (mounted) {
          // print("Login via token failed: ${e.toString()}");
          Navigator.of(context).pushReplacementNamed('login');
        }
      }
    } 
    // Offline Path
    else {
      // print("Device is Offline. Checking for stored user data.");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final privilege = prefs.getInt('privilege');
      final userId = prefs.getInt('id');
      final daoraId = prefs.getInt('currentDaoraId');

      const specialPrivileges = [2, 3, 4];

      if (token != null && privilege != null && userId != null && daoraId != null && specialPrivileges.contains(privilege)) {
        // print("Offline access granted for privilege $privilege.");

        // Populate providers with locally stored data
        user.token = token;
        user.id = userId;
        user.privilege = privilege;
        user.daoraId = daoraId;
        daoraState.setDaoraId(daoraId);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('user_ranking');
        }
      } else {
        // print("Offline access denied or missing data. Navigating to login screen.");
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loading(),
    );
  }
}

// Loading Widget for the UI
class Loading extends StatefulWidget {
  const Loading({super.key});
  @override
  State<StatefulWidget> createState() => LoadingState();
}

class LoadingState extends State<Loading> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);
    animation =
        Tween<double>(begin: 0, end: 2 * 3.1415926535897932).animate(controller)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controller.reset();
              controller.forward();
            }
          });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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