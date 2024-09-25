import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/ReportsScreen.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestsRoot.dart';
import 'package:masjed/screens/admin_screens/testsScreens/TestsRoot.dart';
import 'package:masjed/screens/redirect.dart';
import 'package:masjed/screens/user_screens/waitToTakeTeacher.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/screens/user_screens/user%20home/user_home.dart';
import 'package:masjed/screens/user_screens/user_notifications.dart';
import 'package:masjed/screens/user_screens/user_latest.dart';
import 'package:masjed/screens/user_screens/user_ranking.dart';
import 'package:masjed/screens/user_screens/user_tests.dart';

class UserApp extends StatelessWidget {
  PageController controller = PageController(initialPage:0,keepPage: true);
  GlobalKey<BarState> bar_state = GlobalKey<BarState>();
  GlobalKey<NavigationState> nav_state = GlobalKey<NavigationState>();

  @override
  Widget build(BuildContext context) {
    
    var user =Provider.of<User>(context,listen: false);
    return user.teache_name!=null?  ChangeNotifierProvider<Profile>(
      create: (context) => Profile(),
      child: PopScope(
        canPop: false,
        onPopInvoked: (f){
          if (controller.page != 0) {
            controller.jumpToPage(0);
            return;
          }

        },
        child: Scaffold(
          appBar: Bar(key: bar_state),
          body: PageView(
            onPageChanged: (int i){
              nav_state.currentState?.update(i);
              bar_state.currentState?.update(i);
              },
            controller: controller,
            scrollDirection: Axis.horizontal,
            children: [
              UserHome(),
              UserLatest(),
              UserRanking(),
              TestsRoot(privilege: 1,),
              ReportsScreen()
              // UserNotifications(),
            ],
          ),
          bottomNavigationBar: Navigation(controller,key: nav_state),
        ),
      ),
    ):  WaitToTakeTeacher(user: user,);
  
  }

}



class Bar extends StatefulWidget implements PreferredSizeWidget{
  Bar({required super.key});

  @override
  State<StatefulWidget> createState() => BarState();

  @override
  Size get preferredSize => Size.fromHeight(20);
}

class BarState extends State<Bar> {
  int index = 0;

  void update (int i) {setState(() {index = i;});}

  @override
  Widget build(BuildContext context) {
    return AppBar(backgroundColor: Colors.green ,title: Center(child: Text(page_title[index] as String , style: TextStyle(color: Colors.white),),));
  }

  static final Map<int,String> page_title = {
    0: 'الرئيسية',
    1: 'الاخيرة',
    2: 'المراتب',
    3: 'اختبارات',
    4: 'التقارير'
  };

}


class Navigation extends StatefulWidget {
  final PageController controller;
  const Navigation(this.controller,{super.key});

  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int index = 0;

  void update (int i) {setState(() {index = i;});}

  @override
  Widget build(BuildContext context) {
    return
     BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {widget.controller.jumpToPage(i);},
      items: const [
        BottomNavigationBarItem(
            label: 'رئيسية',
            icon: Icon(Icons.home_rounded)
        ),
        BottomNavigationBarItem(
            label: 'الاخيرة',
            icon: Icon(Icons.watch_later)
        ),
        BottomNavigationBarItem(
            label: 'مراتب',
            icon: Icon(Icons.format_list_numbered_rtl)
        ),
        BottomNavigationBarItem(
            label: 'اختبارات',
            icon: Icon(Icons.text_snippet)
        ),
        BottomNavigationBarItem(
            label: 'التقارير',
            icon: Icon(Icons.stacked_line_chart_rounded)
        ),
      ],
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black38,
      showUnselectedLabels: true,
    );
  }
}

