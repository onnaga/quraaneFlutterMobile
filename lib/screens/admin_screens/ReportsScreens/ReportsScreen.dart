import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/UsersList.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool logging = false;
  final ScrollController firstScrollController = ScrollController();
  List<dynamic> dataFromApi = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);

    return Consumer<Profile>(
      builder: (context, profile, child) {
        // ✅ 1. استبدال Stack بـ Column لتجنب تداخل العناصر
        return Column(
          children: [
            // ✅ 2. استخدام Expanded لجعل القائمة تملأ المساحة المتاحة
            Expanded(
              child: ListView.builder(
                controller: firstScrollController,
                itemCount: dataFromApi.length,
                // إضافة padding للقائمة لتجنب الالتصاق بالحواف
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                itemBuilder: (context, index) {
                  final report = dataFromApi[index];
                  // لم نعد بحاجة لمتغير isHighlighted هنا لأن التصميم انتقل للـ Card
                  
                  // ✅ 3. إزالة Container ذو الارتفاع الثابت
                  // يتم الآن عرض الـ Card مباشرة
                  return usersList(
                    reportForUser: report,
                    user_id_from_api: report['user_id'],
                  );
                },
              ),
            ),
            // ✅ 4. وضع زر التحميل مباشرة بعد القائمة
            // لم نعد بحاجة لـ Align
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تحديث البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DownloaddataBTN(
                  submit: downloadData,
                  logging: logging,
                  profile: profile,
                ),
                // إضافة مساحة سفلية آمنة لتجنب تداخل الزر مع عناصر النظام
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ],
        );
      },
    );
  }

  // قمت بتبسيط هذه الدالة أيضًا باستخدام async/await بشكل أفضل
Future<void> downloadData(Profile profile) async {
  if (!mounted) return;
  setState(() => logging = true); // يعني أن التحميل بدأ

  try {
    // استدعاء الدالة والحصول على البيانات مباشرة
    final List<dynamic> reports = await profile.show_reports();
    
    if (!mounted) return;

    setState(() {
      dataFromApi = reports;
    });

  } catch (e) {
    if (!mounted) return;
    showStyledSnackBar(context, message: e.toString(), isError: true);
    setState(() {
      dataFromApi = []; // إفراغ القائمة عند حدوث خطأ
    });
  } finally {
    if (mounted) {
      setState(() => logging = false); // يعني أن التحميل انتهى
    }
  }
}

}