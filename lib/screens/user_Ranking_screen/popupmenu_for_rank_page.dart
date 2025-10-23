import 'package:flutter/material.dart';
// ... (باقي الاستيرادات)
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestsRoot.dart';
import 'package:masjed/screens/user_screens/showUserProfile/ShowUserHome.dart';
import 'package:masjed/screens/user_screens/user_latest.dart';
import 'package:masjed/state/achievements_cache_service.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';


class popupmenuForRankPage extends StatelessWidget {
  final int user_id;
  final Future<void> Function(BuildContext context, Profile profile) UpdateParent;
  // ✅ 1. إضافة متغير جديد لاستقبال حالة الاتصال
  final bool isOnline;

  const popupmenuForRankPage({
    required this.user_id,
    required this.UpdateParent,
    required this.isOnline, // ✅ 2. جعله مطلوباً
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_outlined),
      onSelected: (value) async {
          // ... (المنطق داخل onSelected يبقى كما هو)
          switch (value) {
          case 1:
            {
              // إظهار مؤشر التحميل
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) =>
                    const Center(child: ModernLoader()),
              );

              try {
                final userProvider = Provider.of<User>(context, listen: false);

                // استدعاء الدالة بدون تمرير context وانتظار النتيجة
                final userProfile = await userProvider.get_user_info(user_id);

                // ✅ التحقق من أن الويدجت ما زالت موجودة قبل استخدام context
                if (!context.mounted) return;

                // إغلاق مؤشر التحميل
                Navigator.of(context).pop();

                // الانتقال للصفحة الجديدة
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.green,
                        title: const Text('الملف الشخصي للطالب',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      body: ShowuserhomeProfile(userToShowprofile: userProfile),
                    ),
                  ),
                );
              } catch (e) {
                // ✅ التحقق أيضاً في حالة حدوث خطأ
                if (!context.mounted) return;

                // إغلاق مؤشر التحميل
                Navigator.of(context).pop();

                // إظهار رسالة الخطأ
                showStyledSnackBar(context,
                    message: e.toString(), isError: true);
              }
            }

            break;
          case 2:
            {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LatestRoot(user_id: user_id),
                ),
              );
            }
            break;
case 3: // عرض الإنجاز السابق
  {
    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(child: ModernLoader()),
    );

    reciveLatest? latestData;

    try {
      if (isOnline) {
        // ===== حالة الاتصال بالإنترنت: جلب أحدث البيانات =====
        final profileProvider = Provider.of<Profile>(context, listen: false);
        final userProvider = Provider.of<User>(context, listen: false);
        latestData = await profileProvider.get_Latest(userProvider.privilege!, user_id);
      } else {
        // ===== حالة عدم الاتصال: القراءة من الكاش =====
        final cacheService = AchievementsCacheService();
        latestData = await cacheService.getAchievementsForUser(user_id);
      }
    } catch (e) {
      // print("Error in popup menu case 3: $e");
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(); // إغلاق مؤشر التحميل
// print("latestData ؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟؟ 3: $latestData");
    if (latestData != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: const Text('آخر الإنجازات',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          // تمرير البيانات المحملة مسبقًا إلى الصفحة
          body: UserLatest.forteacher(userId: user_id, initialData: latestData),
        ),
      ));
    } else {
      // إظهار رسالة إذا لم يتم العثور على بيانات لا أونلاين ولا أوفلاين
      showStyledSnackBar(context, message: 'لا توجد بيانات إنجازات محفوظة لهذا الطالب', isError: true);
    }
    break;
  }
     case 4:
  {
    // لا حاجة لـ Provider هنا إذا لم تكن ستستخدمه قبل الـ await
    User user = Provider.of<User>(context, listen: false);
    Profile profile = Provider.of<Profile>(context, listen: false);

    // 1. استدعاء الدالة بدون تمرير context
    var result = await user.leave_student(user_id);
    
    // 2. (مهم جدًا) التأكد من أن الواجهة ما زالت موجودة قبل استخدام context
    if (!context.mounted) return;

    // 3. التعامل مع النتيجة
    if (result['success'] == true) {
      // في حالة النجاح
      UpdateParent.call(context, profile);
      showStyledSnackBar(context, message: 'تم إخراج الطالب من الحلقة', isError: false);
    
    } else {
      // في حالة الفشل، اعرض الرسالة القادمة من الـ API
      showStyledSnackBar(context,
          message: result['message'], // استخدام الرسالة من النتيجة
          isError: true);
    }
    break;
  
            }
        }
      },
      itemBuilder: (BuildContext) {
        // ✅ 3. بناء القائمة بناءً على حالة الاتصال
        return [
          // يظهر فقط عند وجود انترنت
          if (isOnline)
            const PopupMenuItem(
              value: 1,
              child: Text('الملف الشخصي'),
            ),
          
          // يظهر دائماً
          const PopupMenuItem(
            value: 2,
            child: Text('إضافة آخر الإنجازات'),
          ),

          // يظهر دائماً (بافتراض أنه قد يعمل بدون انترنت)
          const PopupMenuItem(
            value: 3,
            child: Text('عرض الإنجاز السابق',
                style: TextStyle(
                    color:
                        Colors.black)),
          ),

          // يظهر فقط عند وجود انترنت
          if (isOnline)
            const PopupMenuItem(
              value: 4,
              child: Text('إخراج من الحلقة',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ];
      },
    );
  }
}