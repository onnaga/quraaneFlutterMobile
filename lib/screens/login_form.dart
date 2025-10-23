import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/core/widgets/dot_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String? username;
  String? password;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // 1. استخدم هذا المتغير فقط للتحكم في حالة التحميل
  bool _isLoading = false;

  // 2. تم حذف المتغير `Future<bool>? response;` لأنه غير ضروري

  @override
  Widget build(BuildContext context) {
    // sizeConfig().init(context); // تأكد من استدعاء هذا في مكان مناسب في تطبيقك
    return IgnorePointer(
      // 3. استخدم `_isLoading` لتعطيل الواجهة أثناء التحميل
      ignoring: _isLoading,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _buildTextField(
              label: 'اسم المستخدم',
              icon: Icons.person,
              onSaved: (val) => username = val,
              validator: usernameValidator,
            ),
            SizedBox(height: sizeConfig.defaultSize! * 2),
            _buildTextField(
              label: 'كلمة المرور',
              icon: Icons.lock,
              obscure: true,
              onSaved: (val) => password = val,
              validator: passwordValidator,
            ),
            SizedBox(height: sizeConfig.defaultSize! * 5),
            // 4. مرر `_isLoading` إلى زر الإرسال
            SubmitButton(submit, _isLoading),
            SizedBox(height: sizeConfig.defaultSize! * 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'لا أملك حسابا ',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, 'register'),
                  child: const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                        color: Color.fromARGB(255, 37, 34, 211),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    bool obscure = false,
  }) {
    return TextFormField(
      obscureText: obscure,
      style: TextStyle(fontSize: sizeConfig.defaultSize! * 1.4),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        labelStyle: TextStyle(
          fontSize: sizeConfig.defaultSize! * 1.6,
          color: Colors.green[700],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(45.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(45.0),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  String? usernameValidator(String? value) =>
      (value == null || value.isEmpty) ? 'أدخل اسم المستخدم' : null;

  String? passwordValidator(String? value) =>
      (value == null || value.isEmpty) ? 'أدخل كلمة المرور' : null;

  // 5. هذه هي دالة الإرسال الصحيحة التي يجب استخدامها
void submit() async {
  final form = formKey.currentState;
  if (form == null || !form.validate()) {
    return;
  }
  form.save();

  final user = Provider.of<User>(context, listen: false);
  final daoraState = Provider.of<Daorastate>(context, listen: false);

  setState(() {
    _isLoading = true;
  });

  try {
    final bool auth = await user.login(username!, password!);
    if (!context.mounted) return;

    if (auth) {
      // ✅ --- بداية الإضافة ---
      // بعد تسجيل الدخول الناجح، قم بتخزين البيانات الأساسية
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token!);
      await prefs.setInt('id', user.id!);
      await prefs.setInt('privilege', user.privilege!);
      await prefs.setInt('daoraId', user.daoraId); // !! تخزين معرّف الدورة

      // print("Data saved to SharedPreferences: id=${user.id}, privilege=${user.privilege}, daoraId=${user.daoraId}");
      // ✅ --- نهاية الإضافة ---

      daoraState.setDaoraId(user.daoraId);
      Navigator.of(context).popAndPushNamed('redirect');
    }
  } catch (e) {
    if (!context.mounted) return;
    showStyledSnackBar(context, message: e.toString().replaceAll("Exception: ", ""), isError: true);
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
}
// زر الدخول
class SubmitButton extends StatefulWidget {
  final void Function() submit;
  final bool logging;
  const SubmitButton(this.submit, this.logging, {super.key});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.logging) {
          widget.submit();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          width: double.infinity,
          height: sizeConfig.defaultSize! * 5.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.logging
              ? const DotLoader() // استدعاء اللودر اللي عملته
              : const Text(
                  'تسجيل دخول',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
        ),
      ),
    );
  }
}
