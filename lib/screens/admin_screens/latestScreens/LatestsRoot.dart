import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/LatestAct.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestNotes/LatestNotes.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/latestHadith.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/latestquraan.dart';

class LatestRoot extends StatefulWidget {
  final int user_id ;
  const LatestRoot({super.key , required this.user_id});

  @override
  State<LatestRoot> createState() => _LatestRoot();
}

class _LatestRoot extends State<LatestRoot> {



  @override
  Widget build(BuildContext context) {
      final List<Widget> _tabs = [
    Latestquraan(userId:widget.user_id ),
    LatestHadith(userId:widget.user_id),
    LatestActivity(userId: widget.user_id,),
    LatestNote(userId: widget.user_id,),
  ];

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: const TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor:  Color.fromARGB(255, 0, 0, 0),
          dividerColor:Color.fromARGB(255, 94, 136, 80) ,
          tabs: [
            Tab(icon: Icon(Icons.add_chart), text: 'إنجاز القرآن'),
           Tab(
                icon: Icon(Icons.show_chart_rounded),
                text: 'إنجاز الحديث'),
           Tab(
                icon: Icon(Icons.local_activity_rounded),
                text: 'النشاطات'),
           Tab(
                icon: Icon(Icons.note_add_rounded),
                text: 'الملاحظات'),
          
          ],
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
