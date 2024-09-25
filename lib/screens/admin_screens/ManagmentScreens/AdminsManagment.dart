import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/AddAdminsScreen.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/SHowTeacherScreen.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/WaitingStudents.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';



class AdminsManagment extends StatelessWidget {
  AdminsManagment({super.key});

   List<Widget> tabs =  [
    
    TeachersScreen(),
    WaitingStudentsPage()
  ];

  @override
  Widget build(BuildContext context) {
    // WaitingStudentsPage
    User user = Provider.of<User>(context,listen: false);
    user.privilege==3?tabs =  [
    AddAdminsScreen(),
    TeachersScreen(),
    WaitingStudentsPage(),
  ]:  tabs =  tabs;
    return user.privilege==3? 
    /////////////////////////////////////if///////////////////////////////////////
    DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: const TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor: Color.fromARGB(255, 0, 0, 0),
          dividerColor: Color.fromARGB(255, 94, 136, 80),
          tabs: [
            
            Tab(icon: Icon(Icons.account_circle_rounded), text: 'إضافة أستاذ'),
            
            Tab(
                icon: Icon(Icons.supervised_user_circle_sharp),
                text: 'عرض الأساتذة'),
                 
                 Tab(icon: Icon(Icons.watch_later_outlined), text: 'قائمة الانتظار'),
          ],
        ),
        body: TabBarView(
          children: tabs,
        ),
      ),
    ):
    
    /////////////////////////////////////else //////////////////////////////
    DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: const TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor: Color.fromARGB(255, 0, 0, 0),
          dividerColor: Color.fromARGB(255, 94, 136, 80),
          tabs: [
            
           
            
            Tab(
                icon: Icon(Icons.supervised_user_circle_sharp),
                text: 'عرض الأساتذة'),
                 
                 Tab(icon: Icon(Icons.watch_later_outlined), text: 'قائمة الانتظار'),
          ],
        ),
        body: TabBarView(
          children: tabs,
        ),
      ),
    );
  }
}

