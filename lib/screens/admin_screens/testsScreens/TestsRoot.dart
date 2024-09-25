import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/testsScreens/AddTestScreen.dart';
import 'package:masjed/screens/admin_screens/testsScreens/MyTestsScreen.dart';
import 'package:masjed/screens/admin_screens/testsScreens/ShowTests.dart';
import 'package:provider/provider.dart';

class TestsRoot extends StatelessWidget {
final  int privilege;
   TestsRoot({ required this.privilege});
  @override
  Widget build(BuildContext context) {
    List<Widget>_tabs = [];
    _tabs.add(const Showtests());
    privilege==3?_tabs.add(const AddTestsScreen()):true;
    return DefaultTabController(
      length:_tabs.length,
      child: Scaffold(
        appBar: privilege ==3 ? const  TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor:   Color.fromARGB(255, 0, 0, 0),
          dividerColor: Color.fromARGB(255, 94, 136, 80) ,
          tabs: [
            
             Tab(icon: Icon(Icons.add_chart), text: 'الاختبارات'),
             
            Tab(
                icon: Icon(Icons.show_chart_rounded),
                text: ' إضافة اختبار ترشيحي')
       
          ],
        ): 
        const  TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor:   Color.fromARGB(255, 0, 0, 0),
          dividerColor: Color.fromARGB(255, 94, 136, 80) ,
          tabs: [
            Tab(icon: Icon(Icons.add_chart), text: 'الاختبارات'),
            
          ],
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
