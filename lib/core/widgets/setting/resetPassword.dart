import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import '../modern_loader.dart'; // استورد اللودر العصري

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  String oldPassword = "";
  String newPassword = "";
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل كلمة المرور';
    }
    return null;
  }

  Future<void> submit(BuildContext context) async {
    final form = formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    final user = Provider.of<User>(context, listen: false);

    setState(() => isLoading = true);

    try {
      final auth = await user.resetPassword(context, oldPassword, newPassword);
      if (auth == true) {
        showStyledSnackBar(context , message: 'تم تحديث كلمة المرور 🎉' ,isError: false );
     
      } else {
                showStyledSnackBar(context , message: 'يوجد مشكلة في تحديث كلمة المرور ❌' ,isError: true );
      }
    } catch (e) {
                      showStyledSnackBar(context , message: 'حدث خطأ: $e' ,isError: true );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعادة تعيين كلمة المرور',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(193, 30, 141, 30),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 100),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: passwordValidator,
                  style: TextStyle(fontSize: sizeConfig.defaultSize! * 1.4),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: 'كلمة السر القديمة',
                    labelStyle: TextStyle(
                      fontSize: sizeConfig.defaultSize! * 1.6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                  obscureText: true,
                  onSaved: (value) => oldPassword = value ?? "",
                ),
                SizedBox(height: sizeConfig.defaultSize! * 2),
                TextFormField(
                  validator: passwordValidator,
                  style: TextStyle(fontSize: sizeConfig.defaultSize! * 1.4),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'كلمة السر الجديدة',
                    labelStyle: TextStyle(
                      fontSize: sizeConfig.defaultSize! * 1.6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                  ),
                  obscureText: true,
                  onSaved: (value) => newPassword = value ?? "",
                ),
                SizedBox(height: sizeConfig.defaultSize! * 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: sizeConfig.defaultSize! * 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor:const Color.fromARGB(193, 30, 141, 30)
                         ,
                    ),
                    onPressed: isLoading ? null : () => submit(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: ModernLoader(size: 30),
                          )
                        : Text(
                            "تغيير كلمة المرور",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeConfig.defaultSize! * 1.6,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
