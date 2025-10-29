import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class teacherCard extends StatefulWidget {
  final Function(Profile profile) updateScreen;
  final Map<String, dynamic>? data;

  const teacherCard({
    super.key,
    required this.data,
    required this.updateScreen,
  });

  @override
  State<teacherCard> createState() => _teacherCardState();
}

class _teacherCardState extends State<teacherCard> {
  bool loadingDelete = false;
  bool loadingTogglePrivilege = false;

  // ... (All your handler functions like _handleDelete, _handleTogglePrivilege remain the same)
  Future<void> _handleDelete(BuildContext context, User user) async {
    if (widget.data == null || widget.data?['id'] == null) return;

    final int currentUserId = user.id!;
    final int targetUserId = widget.data!['id'];
    final int targetUserPrivilege = widget.data!['privilege'];

    if (currentUserId > targetUserId && user.privilege == targetUserPrivilege) {
      _showSnackBar(context, 'لا يمكنك حذف مشرف  أقدم منك. يرجى التواصل مع مدير الدورة.', success: false);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا الأستاذ؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => loadingDelete = true);
      final bool wasSuccessful = await user.Delete_user(context, targetUserId);
      if (context.mounted) {
        if (wasSuccessful) {
          final profile = Provider.of<Profile>(context, listen: false);
          widget.updateScreen(profile);
          _showSnackBar(context, 'تم حذف الأستاذ بنجاح', success: true);
        } else {
          _showSnackBar(context, 'حدثت مشكلة أثناء الحذف', success: false);
        }
      }
      if (mounted) {
        setState(() => loadingDelete = false);
      }
    }
  }

  Future<void> _handleTogglePrivilege(BuildContext context, User user) async {
    if (widget.data == null || widget.data?['id'] == null) return;

    final int currentUserId = user.id!;
    final int targetUserId = widget.data!['id'];
    final int targetUserPrivilege = widget.data!['privilege'];
    
    if (currentUserId > targetUserId && user.privilege == targetUserPrivilege) {
      _showSnackBar(context, 'لا يمكنك تغيير صلاحية مشرف أقدم منك. يرجى التواصل مع مدير الدورة.', success: false);
      return;
    }

    setState(() => loadingTogglePrivilege = true);
    final result = await user.toggleTeacherPrivilege(targetUserId);
    if (context.mounted) {
      if (result['success'] == true) {
        final profile = Provider.of<Profile>(context, listen: false);
        widget.updateScreen(profile);
        _showSnackBar(context, 'تم تغيير الصلاحية بنجاح', success: true);
      } else {
        _showSnackBar(context, result['message'] ?? 'فشلت عملية تغيير الصلاحية', success: false);
      }
    }
    
    if (mounted) {
      setState(() => loadingTogglePrivilege = false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {required bool success}) {
    showStyledSnackBar(context, message: message, isError: !success);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final data = widget.data;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool canTogglePrivilege = user.privilege == 3 && (user.id != data?['id']);
    final bool canDeleteAdmin = user.privilege == 3 && (user.id != data?['id']);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenWidth - 30,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 12),
              _buildTeacherInfo(data , user.privilege), // <-- The changes are inside this widget
              const SizedBox(height: 14),
              _buildActionButtons(context, user, canTogglePrivilege, canDeleteAdmin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: const AssetImage('images/avatar.png'),
    );
  }

  // ✅ ==================== بداية التعديل هنا ====================
  Widget _buildTeacherInfo(Map<String, dynamic>? data , userPrivilege) {
    final privilege = data?['privilege'];
    final privilegeText = privilege == 3
                ? 'أستاذ ومشرف'
                : 'أستاذ حلقة';

    return Column(
      children: [
        _infoRow(Icons.badge, 'الرقم الخاص: ${data?['id'] ?? '( غير موجود )'}'),
        _infoRow(Icons.person, 'الاسم: ${data?['name'] ?? '( غير موجود )'}'),
        _infoRow(Icons.phone, 'الرقم: ${data?['phone_number'] ?? '( غير موجود )'}', isPhone: data?['phone_number'] != null),
        _infoRow(Icons.cake, 'العمر: ${data?['age'] ?? '( غير موجود )'}'),
        _infoRow(Icons.security, 'الصلاحية: $privilegeText'),
       
        // ✅ إضافة الحقول الجديدة بشكل شرطي
        if (userPrivilege == 3) ...[
          _infoRow(Icons.work_outline, 'العمل: ${data?['job_name'] ?? '( غير محدد )'}'),
          _infoRow(Icons.location_on_outlined, 'السكن: ${data?['area_name'] ?? '( غير محدد )'}'),
          _infoRow(Icons.family_restroom, 'الحالة: ${data?['family_status'] ?? '( غير محدد )'}'),
        ],

        _infoRow(Icons.calendar_today, 'تاريخ الانضمام: ${data?['created_at']?.split('T')[0] ?? '( غير موجود )'}'),
      ],
    );
  }
  // ✅ ==================== نهاية التعديل هنا ====================
Widget _infoRow(IconData icon, String text, {bool isPhone = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Expanded(
          child: isPhone
              ? InkWell(
                  onTap: () async {
                    // 1. استخراج الرقم المحلي من النص
                    String localPhone = text.split(':').last.trim();
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
                  },
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  text,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
        ),
      ],
    ),
  );
}  Widget _buildActionButtons(BuildContext context, User user, bool canTogglePrivilege, bool canDeleteAdmin) {
    // ... This function remains the same
    if (user.privilege != 3) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (canTogglePrivilege)
          _buildTogglePrivilegeButton(context, user),
        if (canTogglePrivilege)
          const SizedBox(width: 8),
        if (canDeleteAdmin)
          _buildDeleteButton(context, user),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context, User user) {
    // ... This function remains the same
    return ElevatedButton.icon(
      onPressed: loadingDelete ? null : () => _handleDelete(context, user),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        backgroundColor: const Color(0xFFEF5350),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      icon: loadingDelete
          ? const SizedBox(width: 18, height: 18, child: ModernLoader(size: 18))
          : const Icon(Icons.delete, size: 18, color: Colors.white),
      label: const Text(
        'حذف',
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTogglePrivilegeButton(BuildContext context, User user) {
    // ... This function remains the same
    final isHalaqaTeacher = widget.data?['privilege'] == 2;
    final buttonText = isHalaqaTeacher ? 'ترقية لمشرف' : 'تغيير لأستاذ حلقة';
    final buttonIcon = isHalaqaTeacher ? Icons.upgrade : Icons.swap_horiz;
    return ElevatedButton.icon(
      onPressed: loadingTogglePrivilege ? null : () => _handleTogglePrivilege(context, user),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: const Color(0xFF42A5F5), // Blue color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      icon: loadingTogglePrivilege
          ? const SizedBox(width: 18, height: 18, child: ModernLoader(size: 18))
          : Icon(buttonIcon, size: 18, color: Colors.white),
      label: Text(
        buttonText,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}