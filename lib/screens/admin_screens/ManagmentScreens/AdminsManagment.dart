import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/AddAdminsScreen.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/SHowTeacherScreen.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/WaitingStudents.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';



class AdminsManagment extends StatelessWidget {

  AdminsManagment({super.key });

   List<Widget> tabs =  [
    
    const TeachersScreen(),
    const WaitingStudentsPage()
  ];

  @override
  Widget build(BuildContext context) {
    // WaitingStudentsPage
    User user = Provider.of<User>(context,listen: false);
    sizeConfig().init(context);
final double tabFontSize = sizeConfig.defaultSize! * 1.5;

    user.privilege==3?tabs =  [
    const AddAdminsScreen(),
    const TeachersScreen(),
    const WaitingStudentsPage(),
  ]:  tabs =  tabs;
  // ✅ الخطوة 2: تحديد قائمة التابات بناءً على الصلاحية
final List<Widget> tabsList;
if (user.privilege == 3) {
  tabsList = const [
    Tab(icon: Icon(Icons.person_add_alt_1), text: 'إضافة أستاذ'),
    Tab(icon: Icon(Icons.people_alt_outlined), text: 'الأساتذة'),
    Tab(icon: Icon(Icons.watch_later_outlined), text: 'الانتظار'),
  ];
} else {
  tabsList = const [
    Tab(icon: Icon(Icons.people_alt_outlined), text: 'الأساتذة'),
    Tab(icon: Icon(Icons.watch_later_outlined), text: 'الانتظار'),
  ];
}
    // ✅ الخطوة 3: بناء واجهة واحدة باستخدام قائمة التابات المحددة
return DefaultTabController(
  // استخدم طول القائمة الديناميكية
  length: tabsList.length,
  child: Scaffold(
    appBar: TabBar(
      
      splashBorderRadius: const BorderRadius.all(Radius.circular(38)),
      indicatorColor: Colors.green,
      labelColor: const Color.fromARGB(255, 0, 0, 0),
      dividerColor: const Color.fromARGB(255, 94, 136, 80),
      // ✨ تطبيق حجم الخط المتجاوب
      labelStyle: TextStyle(
        fontSize: tabFontSize,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: tabFontSize * 0.9,
      ),
      // استخدام قائمة التابات الديناميكية
      tabs: tabsList,
    ),
    body: TabBarView(
      children: tabs,
    ),
  ),
);
  }
}

