// ✅ تم تعديل هذا الملف بالكامل
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ تأكد من استيراد الملف
import 'package:masjed/core/widgets/setting/settingRoot.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/SHowTeacherScreen.dart';
import 'package:masjed/screens/user_Ranking_screen/rank_view.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/user.dart';

class UserRanking extends StatelessWidget {
  const UserRanking({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    final bool canViewTeachersTab = user.privilege == 1 && isOnline;

    // ✅ استدعاء init هنا للاستفادة من sizeConfig في كل مرة يتم بناء الواجهة
    sizeConfig().init(context);

    final List<Tab> tabs = [
      const Tab(text: 'الحلقة'),
      const Tab(text: 'المسجد'),
      if (canViewTeachersTab) const Tab(text: 'الأساتذة'),
    ];

    final List<Widget> tabViews = [
      const RankView(false),
      const RankView(true),
      if (canViewTeachersTab) const TeachersScreen(),
    ];

    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: screenHeight * 0.25,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 1.0,
              flexibleSpace: FlexibleSpaceBar(
                // ✅✨ بداية التعديل الرئيسي هنا
                background: Container(
                  // يمكنك تغيير هذا اللون ليتناسب مع تصميمك
                  color: Colors.white,
                  child: Padding(
                    // استخدام padding متجاوب لجعل الصورة أصغر
                    padding: EdgeInsets.symmetric(
                      vertical: sizeConfig.defaultSize! * 0.5,
                      horizontal: sizeConfig.defaultSize! * 0.5,
                    ),
                    child: Image.asset(
                      'images/ranks.png',
                      // استخدام contain لضمان عرض الصورة كاملة بدون قص
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // ✅✨ نهاية التعديل الرئيسي
              ),
              actions: [
                if (!isOnline)
                  Row(children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "أوفلاين",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'تسجيل الخروج',
                      onPressed: () {
                        logoutFunction(context, user);
                      },
                    ),
                  ])
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.black87,
                    indicatorColor: Colors.green,
                    indicatorWeight: 3.0,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    tabs: tabs,
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: tabViews,
        ),
      ),
    );
  }
}