import 'package:flutter/material.dart';
import 'package:masjed/providers/notification_provider.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/core/widgets/setting/changeDetails.dart';
import 'package:masjed/core/widgets/setting/resetPassword.dart';
import 'package:masjed/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class settingRoot extends StatelessWidget {
  const settingRoot({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "⚙️ الإعدادات",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingCard(
            context,
            icon: Icons.brightness_6_outlined,
            title: "الوضع الليلي",
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingCard(
            context,
            icon: Icons.person_outline,
            title: "تغيير البيانات",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const changeDetails()),
              );
            },
          ),
          _buildSettingCard(
            context,
            icon: Icons.lock_outline,
            title: "تغيير كلمة المرور",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Resetpassword()),
              );
            },
          ),
          const SizedBox(height: 20), // فاصل
          _buildSettingCard(
            context,
            icon: Icons.logout,
            title: "تسجيل الخروج",
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
            onTap: () {
              // ✅ الخطوة 2: استدعاء الدالة وتمرير المتغيرات اللازمة
              logoutFunction(context, user);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }
}

Future<void> logoutFunction(BuildContext context, User user) async {
  // 1. امسح SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // 2. صفّر بيانات كائن المستخدم الذي تم تمريره
  user.token = null;
  user.privilege = null;
  user.id = null;
  user.username = null;

  // 3. صفّر آي دي الدورة
  final daoraState = Provider.of<Daorastate>(context, listen: false);
  daoraState.setDaoraId(0); // لا حاجة لـ await هنا لأنها ليست Future

  // 4. امسح الإشعارات
  final notificationProvider =
      Provider.of<NotificationProvider>(context, listen: false);
  notificationProvider.clear();

  // 5. ارجع لشاشة تسجيل الدخول واحذف كل الراوتات السابقة
  // التحقق من أن الـ context لا يزال صالحًا قبل استخدامه
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      'login',
      (route) => false,
    );
  }
}
