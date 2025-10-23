import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class AddAdminsScreen extends StatefulWidget {
  const AddAdminsScreen({super.key});

  @override
  State<AddAdminsScreen> createState() => _AddAdminsScreenState();
}

class _AddAdminsScreenState extends State<AddAdminsScreen> {
  String? username;
  String? password;
  String? familyStatus;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers هي المصدر الأساسي للحقيقة
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late Future<Map<String, List<String>>> _suggestionsFuture;

  String privilegeValue = "3"; // القيمة الافتراضية هي "استاذ مشرف"
  static List<String> items = ['استاذ حلقة', 'استاذ مشرف'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<User>(context, listen: false);
    _suggestionsFuture = authProvider.fetchSuggestions();
  }

  @override
  void dispose() {
    _jobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, List<String>>>(
        future: _suggestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ModernLoader());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ في تحميل البيانات: ${snapshot.error}'));
          }

          final suggestions = snapshot.data ?? {'jobs': [], 'areas': []};
          final jobSuggestions = suggestions['jobs']!;
          final areaSuggestions = suggestions['areas']!;

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 30),
                          // الحقول الأخرى تبقى كما هي
                          TextFormField(
                            decoration: _inputDecoration('الاسم الثلاثي', Icons.person),
                            onSaved: (String? value) => username = value,
                            validator: usernameValidator,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            obscureText: true,
                            decoration: _inputDecoration('كلمة المرور', Icons.lock_outline),
                            onSaved: (String? value) => password = value,
                            validator: passwordValidator,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration('اختر الصلاحية', Icons.account_tree),
                            value: items[1],
                            onChanged: (String? value) {
                              privilegeValue = value == 'استاذ حلقة' ? "2" : "3";
                            },
                            validator: privilegeValidator,
                            items: items
                                .map<DropdownMenuItem<String>>((String dropdownvalue) {
                              return DropdownMenuItem<String>(
                                value: dropdownvalue,
                                child: Center(
                                  child: Text(
                                    dropdownvalue,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          
                          // ✅ ============= بداية التعديل: حقل الوظيفة =============
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              return jobSuggestions.where((String option) {
                                return option.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (String selection) {
                              _jobController.text = selection;
                              FocusScope.of(context).unfocus();
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextFormField(
                                controller: fieldController,
                                focusNode: fieldFocusNode,
                                onChanged: (value) {
                                  // تحديث الـ controller الرئيسي مع كل حرف يتم كتابته
                                  _jobController.text = value;
                                },
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? "الوظيفة مطلوبة" : null,
                                decoration: _inputDecoration('الوظيفة', Icons.work),
                              );
                            },
                          ),
                          // ✅ ============= نهاية التعديل =============
                          const SizedBox(height: 20),

                          // ✅ ============= بداية التعديل: حقل العنوان =============
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return areaSuggestions.where((String option) {
                                return option.contains(textEditingValue.text);
                              });
                            },
                            onSelected: (String selection) {
                              _addressController.text = selection;
                              FocusScope.of(context).unfocus();
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextFormField(
                                controller: fieldController,
                                focusNode: fieldFocusNode,
                                onChanged: (value) {
                                  _addressController.text = value;
                                },
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? "العنوان مطلوب" : null,
                                decoration: _inputDecoration('العنوان', Icons.home),
                              );
                            },
                          ),
                          // ✅ ============= نهاية التعديل =============
                          const SizedBox(height: 20),

                          TextFormField(
                            decoration: _inputDecoration('الحالة العائلية (اختياري)', Icons.family_restroom),
                            onSaved: (v) => familyStatus = v?.trim(),
                          ),
                          const SizedBox(height: 30),
                          SubmitFormButton(submit: submit),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // دالة مساعدة لتنسيق الحقول
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  // دوال التحقق
  String? privilegeValidator(String? value) {
    if (value != "استاذ حلقة" && value != "استاذ مشرف") {
      return 'اختر نوع التصريح للأستاذ';
    }
    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل اسم المستخدم';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل كلمة المرور';
    }
    return null;
  }

  Future<void> submit() async {
    FormState? form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    form.save(); // لحفظ قيم الحقول العادية

    setState(() => _isLoading = true);

    try {
      final int? daoraId = Provider.of<Daorastate>(context, listen: false).currentDaoraId;
      final User user = Provider.of<User>(context, listen: false);

      // ✅ نقرأ القيم النهائية مباشرة من الـ Controllers
      final bool auth = await user.add_admin(
          username!,
          password!,
          privilegeValue,
          daoraId,
          _jobController.text.trim(),
          _addressController.text.trim(),
          familyStatus);

      if (!context.mounted) return;

      if (auth) {
        showStyledSnackBar(context,
            message: 'تم إضافة الأستاذ بنجاح', isError: false);
      }
    } catch (e) {
      if (!context.mounted) return;
      showStyledSnackBar(context, message: e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}