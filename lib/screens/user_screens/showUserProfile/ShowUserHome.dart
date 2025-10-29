import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/chapters.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/user_screens/user_home/userReport.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowuserhomeProfile extends StatelessWidget {
  final UserToShowProfile userToShowprofile;
  const ShowuserhomeProfile({super.key, required this.userToShowprofile});

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);

    return WillPopScope(
      onWillPop: () async {
        context.read<Profile>().resetDataForUserReport();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            /// ✅ 1. شاشة الملف الشخصي (التي لديك أصلًا)
            ProfileScreenForShow(userToShowprofile: userToShowprofile),

            /// ✅ 2. التقرير بأسلوب DraggableScrollableSheet
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
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
                      // المقبض الصغير في الأعلى
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: sizeConfig.defaultSize! * 1),
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
                        child: UserReport(
                          scrollController: scrollController,
                          user_id: userToShowprofile.id,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreenForShow extends StatefulWidget {
  final UserToShowProfile userToShowprofile;
  const ProfileScreenForShow({super.key, required this.userToShowprofile});

  @override
  State<ProfileScreenForShow> createState() => _ProfileScreenForShowState();
}

class _ProfileScreenForShowState extends State<ProfileScreenForShow> {
  bool isEditing = false;
  bool editChapters = false;

  // ✅ الخطوة 1: تعريف المفتاح للوصول إلى حالة الويدجت Chapters
  final GlobalKey<ChaptersState> _chaptersKey = GlobalKey<ChaptersState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  List<int> selectedChapters = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userToShowprofile.name);
    phoneController =
        TextEditingController(text: widget.userToShowprofile.phone_number);
    ageController =
        TextEditingController(text: widget.userToShowprofile.age.toString());
    selectedChapters = widget.userToShowprofile.ended_quraan ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(sizeConfig.defaultSize! * 2),
      child: Column(
        children: [
          CircleAvatar(
            radius: sizeConfig.defaultSize! * 8,
            backgroundImage: const AssetImage('images/avatar.png'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => isEditing = !isEditing),
            icon: Icon(isEditing ? Icons.visibility : Icons.edit),
            label: Text(isEditing ? "عرض البيانات" : "تعديل البيانات"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditing ? Colors.blue : Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          if (!isEditing)
            Column(
              children: [
                _buildInfoCard(
                    icon: Icons.person,
                    label: "الاسم",
                    value: widget.userToShowprofile.name),


                    
                _buildInfoCard(
                    icon: Icons.phone,
                    label: "الرقم",
                    value: widget.userToShowprofile.phone_number , isLink: true),
                    
                _buildInfoCard(
                    icon: Icons.cake,
                    label: "العمر",
                    value: widget.userToShowprofile.age.toString()),

                       // ✅ ============= بداية الإضافة =============
      _buildInfoCard(
          icon: Icons.work_outline,
          label: "عمل ولي الأمر",
          // استخدام '??' لإظهار قيمة افتراضية في حال كانت البيانات null
          value: widget.userToShowprofile.job_name ?? 'غير محدد'),
_buildInfoCard(
        icon: Icons.location_on_outlined, // أيقونة مناسبة للمكان
        label: "مكان السكن",
        value: widget.userToShowprofile.region ?? 'غير محدد'),
      _buildInfoCard(
          icon: Icons.family_restroom,
          label: "الحالة العائلية",
          value: widget.userToShowprofile.family_status ?? 'غير محدد'),
      // ✅ ============= نهاية الإضافة =============
      const SizedBox(height: 80 ,)
              ],
            )
          else
            Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "الاسم")),
                const SizedBox(height: 8),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "الرقم")),
                const SizedBox(height: 8),
                TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: "العمر"),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => editChapters = !editChapters),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text(editChapters
                      ? "إلغاء تعديل الأجزاء"
                      : "أريد تعديل الأجزاء المسبورة في الأوقاف"),
                ),
                const SizedBox(height: 8),
                if (editChapters)
                  // ✅ الخطوة 2: ربط المفتاح بالويدجت Chapters
                  Chapters(
                    key: _chaptersKey,
                    initialSelected: selectedChapters,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _saveChanges(),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("حفظ التغييرات"),
                ),
                const SizedBox(height: 80),
              ],
            ),
        ],
      ),
    );
  }

Widget _buildInfoCard({
  required IconData icon,
  required String label,
  required String value,
  bool isLink = false,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 3,
    child: ListTile(
      leading: Icon(icon, color: Colors.green, size: 28),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: isLink
          ? TextButton(
          onPressed: () async {
  // 1. استخراج الرقم المحلي من 'value'
  String localPhone = value.trim();
  String internationalPhone = '';

  // 2. التحويل إلى التنسيق الدولي بناءً على القاعدة
  // Regex: (09\d{8}) -> 10 أرقام
  if (localPhone.startsWith('09') && localPhone.length == 10) {
    internationalPhone = '963${localPhone.substring(1)}'; // -> 9639...
  } 
  // Regex: (05\d{9}) -> 11 رقم
  else if (localPhone.startsWith('05') && localPhone.length == 11) {
    internationalPhone = '90${localPhone.substring(1)}'; // -> 905...
  } 
  else {
    // في حال كان الرقم غير مطابق
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("رقم الهاتف غير صالح لفتحه في واتساب")),
      );
    }
    return;
  }

  // 3. إنشاء الرابط بالرقم الدولي
  final url = Uri.parse("https://wa.me/$internationalPhone");

  // 4. محاولة الفتح
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن فتح واتساب (تأكد من تثبيته)")),
      );
    }
  }
}, child: Text(
                value,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          : Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
    ),
  );
}

Future<void> _saveChanges() async {
  // ✅ الخطوة 1: التحقق من صحة المدخلات
  final String name = nameController.text.trim();
  final String phone = phoneController.text.trim();
  final int? age = int.tryParse(ageController.text.trim());

  if (name.isEmpty || phone.isEmpty || age == null || age <= 0) {
    // استخدام الدالة المساعدة لعرض رسالة خطأ أنيقة
    if (mounted) {
      showStyledSnackBar(
        context,
        message: 'الرجاء تعبئة جميع الحقول بشكل صحيح.',
        isError: true,
      );
    }
    return;
  }

  // ✅ الخطوة 2: عرض مؤشر التحميل
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: ModernLoader()),
  );

  try {
    // ✅ الخطوة 3: استدعاء دالة الـ Provider وانتظار النتيجة
    final profile = context.read<Profile>();

    // جلب الأجزاء المحدّثة من الويدجت Chapters عبر المفتاح
    final List<int> currentSelectedChapters =
        _chaptersKey.currentState?.get_chapters() ?? selectedChapters;

    final result = await profile.updateUserData(
      userId: widget.userToShowprofile.id,
      name: name,
      phone: phone,
      age: age,
      chapters: editChapters ? currentSelectedChapters : null,
    );
    
    // ✅ الخطوة 4: التحقق من أن الويدجت ما زالت موجودة قبل أي عملية
    if (!mounted) return;

    final bool success = result['success'];
    final String message = result['message'];

    // عرض الرسالة المستلمة من الدالة (نجاح أو فشل)
    showStyledSnackBar(context, message: message, isError: !success);

    // ✅ الخطوة 5: تحديث الحالة المحلية في الواجهة فقط عند النجاح
    if (success) {
      setState(() {
        widget.userToShowprofile.name = name;
        widget.userToShowprofile.phone_number = phone;
        widget.userToShowprofile.age = age;
        if (editChapters) {
          widget.userToShowprofile.ended_quraan = currentSelectedChapters;
          selectedChapters = currentSelectedChapters;
        }
        isEditing = false;
        editChapters = false;
      });
    }
  } catch (e) {
    // ✅ الخطوة 6: معالجة الأخطاء غير المتوقعة (مثل مشاكل الشبكة)
    if (!mounted) return;
    showStyledSnackBar(
      context,
      message: 'حدث خطأ غير متوقع: $e',
      isError: true,
    );
  } finally {
    // ✅ الخطوة 7: إغلاق مؤشر التحميل دائماً في النهاية
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}
}