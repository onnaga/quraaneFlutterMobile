import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitingStudentsPage extends StatefulWidget {
  const WaitingStudentsPage({super.key});
  @override
  State<WaitingStudentsPage> createState() => _WaitingStudentsPageState();
}

class _WaitingStudentsPageState extends State<WaitingStudentsPage> {
  bool logging = false;
  final firstScrollController = ScrollController();
  List<dynamic> DataFromApi = [];
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Consumer<Profile>(
      builder: (context, profile, child) {
        return Stack(
          children: [
            ListView.builder(
              controller: firstScrollController,
              itemCount: DataFromApi.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 252, 249, 249),
                    boxShadow: [
                      BoxShadow(color: Colors.green, spreadRadius: 0.1),
                    ],
                  ),
                  height: 130,
                  child: WantingList(
                    reportForUser: DataFromApi[index],
                    user_id_from_api: DataFromApi[index]['user_id'],
                    parentUpdate: DownloadData,
                  ),
                );
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'تحديث البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DownloaddataContextBTN(
                    submit: DownloadData,
                    logging: logging,
                    profile: profile,
                    sendedContext: context),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
Future<void> DownloadData(BuildContext context, Profile profile) async {
  if (!mounted) return;
  setState(() {
    logging = true; // ابدأ باللودر
  });

  try {
    // جلب daoraId قبل استدعاء الدالة
    final daoraId = Provider.of<Daorastate>(context, listen: false).currentDaoraId!;
    // استدعاء الدالة وتمرير daoraId
    final List<Map<String, dynamic>> users = await profile.show_users_without_teacher(daoraId);

    if (!mounted) return;

    setState(() {
      DataFromApi = users;
    });

  } catch (e) {
    if (!mounted) return;
    showStyledSnackBar(context, message: e.toString(), isError: true);
    setState(() {
      DataFromApi = [];
    });
  } finally {
    if (mounted) {
      setState(() {
        logging = false; // أوقف اللودر
      });
    }
  }
}
}

class WantingList extends StatefulWidget {
  final dynamic reportForUser;
  final int user_id_from_api;
  final Future<void> Function(BuildContext context, Profile profile)
      parentUpdate;

  const WantingList({
    super.key,
    required this.reportForUser,
    required this.user_id_from_api,
    required this.parentUpdate,
  });

  @override
  State<WantingList> createState() => _WantingListState();
}

class _WantingListState extends State<WantingList> {
  bool loadingTake = false;
  bool loadingDelete = false;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: const Image(image: AssetImage('images/avatar.png')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "الاسم : ${widget.reportForUser['name']} ",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "العمر : ${widget.reportForUser['age'].toString()} ",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.black),
                ),
InkWell(
  onTap: () async {
    final phone = widget.reportForUser['phone_number'].toString();
    final url = Uri.parse("https://wa.me/$phone"); // ✅ فورمات واتساب الرسمي
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن فتح واتساب")),
      );
    }
  },
  child: Text(
    "الرقم : ${widget.reportForUser['phone_number'].toString()} ",
    textDirection: TextDirection.rtl,
    style: const TextStyle(
      color: Colors.blue, // خلي الرقم أزرق مثل اللينكات
      decoration: TextDecoration.underline, // خط سفلي يوحي انه رابط
    ),
  ),
),

                Text(
                  "الأجزاء المحفوظة : ${widget.reportForUser['ended_quraan_in_aukaf'].toString()} ",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (user.privilege != 4)
            Column(
              children: [
                // زر استلام الطالب
 ElevatedButton(
  onPressed: loadingTake
      ? null
      : () async {
          setState(() => loadingTake = true);
          
          try {
            Profile profile = Provider.of<Profile>(context, listen: false);
            // استدعاء الدالة بدون context
            bool success = await profile.take_student(widget.user_id_from_api);

            if (!mounted) return;

            if (success) {
              // قم بتحديث الواجهة الأصلية إذا لزم الأمر
              await widget.parentUpdate(context, profile);
              showStyledSnackBar(context, message: 'تم استلام الطالب بنجاح');
            }
          } catch (e) {
            if (!mounted) return;
            showStyledSnackBar(context, message: e.toString(), isError: true);
          } finally {
            if (mounted) {
              setState(() => loadingTake = false);
            }
          }
        },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    shadowColor: Colors.black45,
    elevation: 5,
    shape: const StadiumBorder(),
  ),
  child: loadingTake
      ? const ModernLoader(size: 20)
      : const Text('استقبال الطالب', style: TextStyle(color: Colors.white)),
),
 const SizedBox(height: 6),
                // زر الحذف
                // زر الحذف
                ElevatedButton(
                  onPressed: loadingDelete
                      ? null
                      : () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('تحذير!'),
                              content: const Text(
                                  'سيتم حذف حساب الطالب وجميع إنجازاته وتقاريره ونقاطه وإشعاراته. '
                                  'من الأفضل إعلام الطالب بالتسجيل في دورة أخرى لتجنب فقدان بياناته.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (!confirm) return;

                          setState(() => loadingDelete = true);

                          bool deleted = await user.Delete_user(
                              context, widget.user_id_from_api);
                          if (deleted) {
                            Profile profile =
                                Provider.of<Profile>(context, listen: false);
                            await widget.parentUpdate(context, profile);
                          }

                          setState(() => loadingDelete = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shadowColor: Colors.black45,
                    elevation: 5,
                    shape: const StadiumBorder(),
                  ),
                  child: loadingDelete
                      ? const ModernLoader(size: 20)
                      : const Text('حذف',
                          style: TextStyle(color: Colors.white)),
                )
              ],
            ),
        ],
      ),
    );
  }
}
