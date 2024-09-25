import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/widgets/logoutButton.dart';
import 'package:masjed/core/widgets/setting/settingRoot.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/AdminsManagment.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/ReportsScreen.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestsRoot.dart';
import 'package:masjed/screens/admin_screens/testsScreens/TestsRoot.dart';
import 'package:masjed/screens/user_screens/user_ranking.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class AdminApp extends StatelessWidget {
  PageController controller = PageController(initialPage: 0, keepPage: true);
  GlobalKey<BarState> bar_state = GlobalKey<BarState>();
  GlobalKey<NavigationState> nav_state = GlobalKey<NavigationState>();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (f) {
        if (controller.page != 0) {
          controller.animateToPage(0,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
          return;
        }
        // showDialog(
        //     context: context,
        //     barrierDismissible: true,
        //     builder: (context) => ExitAlert());
      },
      child: Scaffold(
        appBar: Bar(key: bar_state),
        body: PageView(
          onPageChanged: (int i) {
            nav_state.currentState?.update(i);
            bar_state.currentState?.update(i);
          },
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: [
            AdminsManagment(),
            UserRanking(),
            TestsRoot(privilege: user.privilege!),
            ReportsScreen(),
          ],
        ),
        bottomNavigationBar: Navigation(controller, key: nav_state),
      ),
    );
  }
}

class Bar extends StatefulWidget implements PreferredSizeWidget {
  Bar({required super.key});

  @override
  State<StatefulWidget> createState() => BarState();

  @override
  Size get preferredSize => Size.fromHeight(40);
}

class BarState extends State<Bar> {
  int index = 0;

  void update(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
  var user =Provider.of<User>(context,listen: false);

    return Padding(
      padding: const EdgeInsets.only(),
      child: AppBar(
        
          backgroundColor: Colors.green,
                    centerTitle: true,
          title: Text(
            page_title[index] as String,
            style: TextStyle(color: Colors.white),
          ),
          leading: logOutButton(user: user),
          actions: [
                              GestureDetector(
                    child: Icon(Icons.settings),
                    onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: 
                (context) => 
                (settingRoot()),),);                          
                
                },
                  ),
                


          ],
),
    );
  }

  static final Map<int, String> page_title = {
    0: 'إدارة المستخدمين',
    1: 'المراتب',
    2: 'الاختبارات',
    3: 'التقارير',
  };
}

class Navigation extends StatefulWidget {
  final PageController controller;
  const Navigation(this.controller, {super.key});

  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int index = 0;

  void update(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        widget.controller.animateToPage(i,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      },
      items: const [
        BottomNavigationBarItem(
            label: 'إدارة المستخدمين', icon: Icon(Icons.accessibility_rounded)),
        BottomNavigationBarItem(
            label: 'الأخيرة', icon: Icon(Icons.timelapse_rounded)),
        BottomNavigationBarItem(
            label: 'الاختبارات', icon: Icon(Icons.text_snippet_rounded)),
        BottomNavigationBarItem(
            label: 'التقارير', icon: Icon(Icons.data_exploration_rounded)),
      ],
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black38,
      showUnselectedLabels: true,
    );
  }
}
