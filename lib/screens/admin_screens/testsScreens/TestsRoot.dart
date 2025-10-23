import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/testsScreens/AddTestScreen.dart';
import 'package:masjed/screens/admin_screens/testsScreens/ShowTests.dart';

class TestsRoot extends StatelessWidget {
  final int privilege;
  const TestsRoot({super.key, required this.privilege});

  @override
  Widget build(BuildContext context) {
    // ✅ تعريف الـ tabs (الشاشات) حسب الصلاحية
    final List<Widget> tabViews = [
      const Showtests(),
      if (privilege == 3) const AddTestsScreen(),
    ];

    // ✅ تعريف الـ عناوين الـ Tabs حسب الصلاحية
    final List<Tab> tabHeaders = [
      const Tab(icon: Icon(Icons.add_chart), text: 'الاختبارات'),
      if (privilege == 3)
        const Tab(icon: Icon(Icons.show_chart_rounded), text: 'إضافة اختبار ترشيحي'),
    ];

    return DefaultTabController(
      length: tabViews.length,
      child: Scaffold(
        appBar: TabBar(
          splashBorderRadius: const BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor: Colors.black,
          dividerColor: const Color.fromARGB(255, 94, 136, 80),
          tabs: tabHeaders,
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
