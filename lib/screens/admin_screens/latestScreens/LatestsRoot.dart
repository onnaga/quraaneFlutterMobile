import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ الخطوة 1: استيراد sizeConfig
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/LatestAct.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestNotes/LatestNotes.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/latestHadith.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/latestquraan.dart';

class LatestRoot extends StatefulWidget {
  final int user_id;
  const LatestRoot({super.key, required this.user_id});

  @override
  State<LatestRoot> createState() => _LatestRoot();
}

class _LatestRoot extends State<LatestRoot> {
  @override
  Widget build(BuildContext context) {
    // ✅ الخطوة 2: تهيئة sizeConfig
    sizeConfig().init(context);
    final double tabFontSize = sizeConfig.defaultSize! * 1.4;

    final List<Widget> tabsContent = [
      Latestquraan(userId: widget.user_id),
      LatestHadith(userId: widget.user_id),
      LatestActivity(
        userId: widget.user_id,
      ),
      LatestNote(
        userId: widget.user_id,
      ),
    ];

    return DefaultTabController(
      length: tabsContent.length,
      child: Scaffold(
        // ✅ الخطوة 3: إزالة const وتطبيق الخصائص الجديدة
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
            fontSize: tabFontSize * 0.9, // الخط غير المحدد أصغر قليلاً
          ),
          tabs: const [
            // ✨ تقصير النصوص لتوفير مساحة
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'القرآن'),
            Tab(icon: Icon(Icons.book_outlined), text: 'الحديث'),
            Tab(icon: Icon(Icons.local_activity_rounded), text: 'النشاطات'),
            Tab(icon: Icon(Icons.note_add_rounded), text: 'الإنذارات'),
          ],
        ),
        body: TabBarView(
          children: tabsContent,
        ),
      ),
    );
  }
}