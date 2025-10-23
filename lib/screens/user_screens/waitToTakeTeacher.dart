import 'package:flutter/material.dart';
import 'package:masjed/screens/DaoraSelectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitToTakeTeacher extends StatefulWidget {
  final dynamic user;
  const WaitToTakeTeacher({this.user, super.key});

  @override
  State<WaitToTakeTeacher> createState() => _WaitToTakeTeacherState();
}

class _WaitToTakeTeacherState extends State<WaitToTakeTeacher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  Future<void> _handleChangeDaora() async {
  final prefs = await SharedPreferences.getInstance();

  // 🔑 خزن البريفليج 10 لتمييز حالة "تغيير الدورة"
  await prefs.setInt('privilege', 10);

  if (widget.user != null) {
    widget.user.privilege = 10;
  }

  if (mounted) {
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const DaoraSelectionPage()),
  (route) => false,
);}
}
Future<void> _handleGoBack() async {
  // 🧹 امسح كل البيانات من SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // 🧹 صفّر بيانات المستخدم الممرر (لو موجود)
  if (widget.user != null) {
    widget.user.token = null;
    widget.user.privilege = null;
    widget.user.id = null;
    widget.user.username = null;
  }

  // 🚪 ارجع لشاشة تسجيل الدخول واحذف كل الراوتات السابقة
  if (mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      'login',
      (route) => false,
    );
  }
}
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // خلفية فاتحة
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الصورة ثابتة
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1B5E20), // أخضر داكن
                      Color(0xFF43A047), // أخضر متوسط
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    "images/penalty.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // النص مع أنيميشن نبض
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Text(
                  'تواصل مع الإدارة لإرشادك إلى حلقتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF2E7D32),
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // زر أنيق
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.redAccent.withOpacity(0.5),
                ),
                onPressed: _handleGoBack,
                child: const Text(
                  "🔄 إعادة المحاولة",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10,),

              ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700],
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 8,
  ),
  onPressed: _handleChangeDaora,
  child: const Text(
    "📚 اختيار دورة جديدة",
    style: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
