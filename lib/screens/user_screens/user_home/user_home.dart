import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/screens/user_screens/user_home/profile_screen.dart';
import 'package:masjed/screens/user_screens/user_home/userReport.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

// استيراد ProfileScreen الجديد

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context); // تهيئة sizeConfig هنا أيضاً إذا لم تكن مهيأة في Root

    return Scaffold( // أضف Scaffold هنا لتوفير بنية أساسية
      // يمكنك إضافة AppBar هنا إذا كنت تريده لـ UserHome بأكمله
      // appBar: AppBar(title: const Text('الملف الشخصي والتقرير')),
      body: Stack(
        children: [
          // ✅ 1. ProfileScreen في الخلفية
          // تأكد من أن ProfileScreen لا يحتوي على SingleChildScrollView خارجي
          // لأنه سيتم تضمينه داخل Stack وسيتعامل مع المساحة المتاحة له.
          const ProfileScreen(),

          // ✅ 2. DraggableScrollableSheet في المقدمة للتقرير
          DraggableScrollableSheet(
            initialChildSize: 0.15, // الحجم الأولي للبطاقة (جزء صغير ظاهر)
            minChildSize: 0.15,    // الحد الأدنى للحجم
            maxChildSize: 0.9,     // الحد الأقصى للحجم (يغطي معظم الشاشة)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor, // لون خلفية البطاقة
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // المقبض (Handle) الذي يسحبه المستخدم
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: sizeConfig.defaultSize! * 1),
                      child: Container(
                        height: 5,
                        width: sizeConfig.defaultSize! * 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Expanded(
                      // ✅ UserReport ملف التقرير سيأتي هنا
                      // يجب أن يستخدم UserReport الـ ScrollController
                      // المزود من DraggableScrollableSheet ليتمكن من التمرير
                      child: UserReport(
                        scrollController: scrollController,
                        user_id: Provider.of<User>(context).details?['id'] ?? 0, // قم بتمرير الـ user_id
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
