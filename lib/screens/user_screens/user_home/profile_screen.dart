import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/setting/changeDetails.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
// تأكد من أن هذا المسار صحيح

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    final theme = Theme.of(context); // للوصول إلى ألوان وتنسيقات الثيم

    return Consumer<User>(
      builder: (context, user, child) {
        return Scaffold( // ✅ أضفنا Scaffold هنا
          body: SingleChildScrollView(
            padding: EdgeInsets.all(sizeConfig.defaultSize! * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: sizeConfig.defaultSize! * 3),

                /// صورة البروفايل مع تأثير بسيط
                GestureDetector(
                  onTap: () {
                    // يمكنك هنا إضافة منطق تغيير الصورة لاحقاً
                  },
                  child: CircleAvatar(
                    radius: sizeConfig.defaultSize! * 8,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (user.image == null)
                        ? const AssetImage('images/avatar.png') as ImageProvider
                        : FileImage(user.image as File),
                  ),
                ),

                SizedBox(height: sizeConfig.defaultSize! * 2),

                Text(
                  user.username ?? "اسم المستخدم",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const Divider(thickness: 1.2, height: 30),

                /// البيانات داخل كروت بتصميم محسن
                _buildInfoCard(
                  icon: Icons.phone_android,
                  label: 'الرقم',
                  value: user.details?['phone']?.toString() ?? "غير متوفر",
                ),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  label: 'العمر',
                  value: (user.details?['age'] ?? "غير متوفر").toString(),
                ),
                _buildInfoCard(
                  icon: Icons.work_outline,
                  label: 'العمل',
                  value: user.details?['job']?.toString() ?? "غير متوفر",
                ),
                _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'مكان السكن',
                  value: user.details?['address']?.toString() ?? "غير متوفر",
                ),
                _buildInfoCard(
                  icon: Icons.family_restroom,
                  label: 'الحالة العائلية',
                  value: user.details?['family_status']?.toString() ?? "غير متوفر",
                ),
                _buildInfoCard(
                  icon: Icons.supervisor_account_rounded,
                  label: 'المدرس',
                  value: user.teache_name ?? "لا يوجد",
                ),
                SizedBox(height: sizeConfig.defaultSize! * 4),

                // زر تعديل التفاصيل
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("تعديل التفاصيل الشخصية"),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const changeDetails()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// مكون معاد استخدامه بتصميم محسن
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    // التأكد من أن القيمة ليست فارغة لعرضها بشكل أفضل
    final displayValue = (value.isEmpty || value == 'null') ? "غير محدد" : value;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 28),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        subtitle: Text(
          displayValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}