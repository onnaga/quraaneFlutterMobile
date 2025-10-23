import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/screens/redirect.dart';
import 'package:masjed/screens/super_admin_screens/add_daora_bage.dart';
import 'package:masjed/screens/super_admin_screens/jobAndAreasScreen.dart';
import 'package:masjed/screens/super_admin_screens/super_admin_app.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/daoraState.dart';

class DaoraSelectionPage extends StatefulWidget {
  const DaoraSelectionPage({super.key});

  @override
  State<DaoraSelectionPage> createState() => _DaoraSelectionPageState();
}

class _DaoraSelectionPageState extends State<DaoraSelectionPage> {
  List<dynamic> daoras = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDaoras();
  }
Future<void> fetchDaoras() async {
  final daorastate = Provider.of<Daorastate>(context, listen: false);
  try {
    final list = await daorastate.getAllDaoras();
    if (mounted) { // التحقق من أن الواجهة ما زالت موجودة
      setState(() {
        daoras = list;
        loading = false;
      });
    }
  } catch (e) {
    // التقط الخطأ واعرض SnackBar هنا
    if (mounted) {
      showStyledSnackBar(context,
          message: e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() {
        loading = false; // لا تنس إيقاف التحميل عند حدوث خطأ
      });
    }
  }
}
  bool _canShowDaora(Map<String, dynamic> daora, int? privilege) {
    if (privilege == null) return true; // غير مسجل → كل الدورات
    if (privilege == 4) return true; // مدير → كل الدورات
    return daora["showable"] == 1; // باقي الحالات → فقط showable
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> daora, int? privilege) {
    List<Widget> buttons = [];

    if (privilege == null) {
      // مستخدم جديد → اختيار
      buttons.add(
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              "id": daora["daora_id"],
              "name": daora["daora_name"],
            });
          },
          child: const Text("اختيار"),
        ),
      );
    } else if (privilege == 10) {
  // حالة تغيير الدورة
  buttons.add(
    ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      onPressed: () async {
        final user = Provider.of<User>(context, listen: false);
        final daoraState = Provider.of<Daorastate>(context, listen: false);

        // 1. استدعاء التابع بدون context وانتظار النتيجة
        final result = await daoraState.changeMyDaora(user.id!, daora["daora_id"]);

        // 2. التحقق من أن الواجهة ما زالت موجودة
        if (!context.mounted) return;

        // 3. التعامل مع النتيجة
        if (result['success'] == true) {
          // في حالة النجاح، قم بتحديث privilege وانتقل
          Provider.of<User>(context, listen: false).privilege = 1;

          showStyledSnackBar(context,
              message: "تم تغيير الدورة بنجاح ✅", isError: false);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Redirect()),
            (route) => false,
          );
        } else {
          // في حالة الفشل، اعرض رسالة الخطأ
          showStyledSnackBar(context,
              message: result['message'], isError: true);
        }
      },
      child: const Text("تغيير الدورة"),
    ),
  );
} else {
      // باقي الحالات → تصفح
      buttons.add(
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => superAdminApp(
                  daoraId: daora["daora_id"],
                ),
              ),
            );
          },
          child: const Text("تصفح"),
        ),
      );
    }

    // زر الإزالة خاص بالمدير
    if (privilege == 4) {
      final user = Provider.of<User>(context, listen: false);
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final daorastate = Provider.of<Daorastate>(context, listen: false);
            String msg = await daorastate.deleteDaora(
                daora["daora_id"], user.token);

            if (context.mounted) {
              showStyledSnackBar(context, message: msg, isError: false);
            }

            setState(() {
              daoras.removeWhere((d) => d["daora_id"] == daora["daora_id"]);
            });
          },
          child: const Text("إزالة", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return buttons;
  }

  Widget _buildDaoraCard(Map<String, dynamic> daora, int? privilege) {
    return FutureBuilder<String?>(
      future: Provider.of<Daorastate>(context, listen: false)
          .getDaoraPhotos(daora["daora_id"]),
      builder: (context, snapshot) {
        Widget leadingWidget;
        if (snapshot.connectionState == ConnectionState.waiting) {
          leadingWidget = const SizedBox(
            width: 40,
            height: 40,
            child: ModernLoader(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          leadingWidget = Image.memory(
            base64Decode(snapshot.data!),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        } else {
          leadingWidget = const Icon(Icons.mosque, size: 40);
        }

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: leadingWidget,
            title: Text(daora["daora_name"] ?? ''),

            // ✅ الحل: استخدم Column لعرض أكثر من سطر في الـ subtitle
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("المدير: ${daora["admin_name"] ?? 'غير محدد'}"),

                // ✅ هذا هو السطر المُصحح
                Text("عدد المسجلين: ${daora["number_of_students"] ?? 0}"),
              ],
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildActionButtons(daora, privilege),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final privilege = user.privilege; // نستخدمه بدال widget.privilege

    return Scaffold(
      appBar: AppBar(title: const Text("اختر الدورة")),
      body: loading
          ? const Center(child: ModernLoader())
          : daoras.isEmpty
              ? Column(children: [
                  const Center(child: Text("لا توجد دورات متاحة")),
                  if (privilege == 4) addDaoraBtn()
                ])
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: daoras.length,
                        itemBuilder: (context, index) {
                          var daora = daoras[index];
                          if (!_canShowDaora(daora, privilege)) {
                            return const SizedBox.shrink();
                          }
                          return _buildDaoraCard(daora, privilege);
                        },
                      ),
                    ),

                    // زر إضافة دورة جديدة (مدير فقط)

                    if (privilege == 4) addDaoraBtn(),
                    if (privilege == 4)
                      IconButton(
                        icon: const Icon(Icons.work_history_outlined),
                        tooltip: 'عرض الأعمال والمناطق',
                        onPressed: () {
                          // ✅ التنقل إلى الصفحة الجديدة
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const JobsAndAreasScreen()),
                          );
                        },
                      ),
                  ],
                ),
    );
  }

  Widget addDaoraBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDaoraPage()),
            );

            if (result == true) {
              fetchDaoras(); // تحديث القائمة
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("إضافة دورة جديدة"),
        ),
      ),
    );
  }
}
