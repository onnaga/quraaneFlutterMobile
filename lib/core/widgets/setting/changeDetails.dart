import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/pulse_loader.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class changeDetails extends StatefulWidget {
  const changeDetails({super.key});

  @override
  State<changeDetails> createState() => _changeDetailsState();
}

class _changeDetailsState extends State<changeDetails> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? age;
  // Controllers تبقى كما هي، فهي المصدر الصحيح للحالة
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _familyStatusController = TextEditingController();

  late Future<Map<String, List<String>>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);
    _suggestionsFuture = user.fetchSuggestions();

    // تهيئة الـ Controllers بالقيم الحالية للمستخدم
    _phoneController.text = user.details?['phone']?.toString() ?? '';
    _jobController.text = user.details?['job']?.toString() ?? '';
    _addressController.text = user.details?['address']?.toString() ?? '';
    _familyStatusController.text =
        user.details?['family_status']?.toString() ?? '';

    age = int.tryParse(user.details?['age']?.toString() ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _jobController.dispose();
    _addressController.dispose();
    _familyStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل التفاصيل الشخصية'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: _suggestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ModernLoader());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('خطأ في تحميل البيانات: ${snapshot.error}'));
          }

          final suggestions = snapshot.data ?? {'jobs': [], 'areas': []};
          final jobSuggestions = suggestions['jobs']!;
          final areaSuggestions = suggestions['areas']!;

          return Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // حقل رقم الهاتف (بدون تغيير)
                  TextFormField(
                    controller: _phoneController,
                    validator: phoneNumberValidator,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                        'رقم الهاتف', Icons.phone_android_rounded),
                  ),
                  const SizedBox(height: 20),

                  // حقل العمر (بدون تغيير)
                  DropdownButtonFormField<int>(
                    value: age,
                    onChanged: (int? v) => setState(() => age = v),
                    validator: ageValidator,
                    decoration: _inputDecoration('العمر', Icons.calendar_today)
                        .copyWith(hintText: 'اختر العمر'),
                    items: List.generate(
                      70,
                      (i) => DropdownMenuItem<int>(
                        value: i + 1,
                        child: Text((i + 1).toString()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ ============= بداية التعديل: حقل الوظيفة =============
                  // نستخدم Autocomplete القياسي مع ربطه بالـ Controller بشكل صحيح
                  Autocomplete<String>(
                    // نعطي الـ Controller الخاص بنا كقيمة أولية
                    initialValue: TextEditingValue(text: _jobController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      // إذا كان الحقل فارغاً، لا تظهر اقتراحات
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      // فلترة الاقتراحات بناءً على ما يكتبه المستخدم
                      return jobSuggestions.where((String option) {
                        return option.contains(textEditingValue.text);
                      });
                    },
                    onSelected: (String selection) {
                      // عند اختيار اقتراح، قم بتحديث الـ Controller
                      _jobController.text = selection;
                      // إزالة التركيز من الحقل بعد الاختيار
                      FocusScope.of(context).unfocus();
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      // هنا نربط الـ Controller الداخلي بالـ Controller الخاص بنا
                      // هذا يضمن أن أي تغيير (كتابة أو اختيار) ينعكس فوراً
                      // ويتم حفظه حتى عند إعادة بناء الواجهة
                      return TextFormField(
                        controller: fieldController,
                        focusNode: fieldFocusNode,
                        onChanged: (value) {
                          // الأهم: تحديث الـ controller الرئيسي مع كل حرف يتم كتابته
                          _jobController.text = value;
                        },
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "الوظيفة مطلوبة"
                            : null,
                        decoration: _inputDecoration('الوظيفة', Icons.work),
                      );
                    },
                  ),
                  // ✅ ============= نهاية التعديل =============
                  const SizedBox(height: 20),

                  // ✅ ============= بداية التعديل: حقل العنوان =============
                  Autocomplete<String>(
                    initialValue:
                        TextEditingValue(text: _addressController.text),
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
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "العنوان مطلوب"
                            : null,
                        decoration:
                            _inputDecoration('مكان السكن', Icons.home),
                      );
                    },
                  ),
                  // ✅ ============= نهاية التعديل =============
                  const SizedBox(height: 20),

                  // حقل الحالة العائلية (بدون تغيير)
                  TextFormField(
                    controller: _familyStatusController,
                    decoration: _inputDecoration(
                        'الحالة العائلية (اختياري)', Icons.family_restroom),
                  ),
                  const SizedBox(height: 40),

                  // زر الحفظ (بدون تغيير)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.save_alt),
                      label: const Text("حفظ التعديلات",
                          style: TextStyle(fontSize: 16)),
                      onPressed: () => submit(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- باقي الدوال المساعدة ودالة submit تبقى كما هي ---
  // --- لا حاجة لتعديلها لأنها تقرأ القيم بشكل صحيح من الـ Controllers ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.green[800]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  String? phoneNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل رقم الهاتف';
    final regex = RegExp(r'^(09\d{8}|05\d{9})$');
    if (!regex.hasMatch(value.trim())) {
      return 'الرقم يجب أن يكون سوري (09..) أو تركي (05..)';
    }
    return null;
  }

  String? ageValidator(int? value) {
    if (value == null) return 'اختر العمر';
    return null;
  }

  void submit(BuildContext context) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: PulseLoader(size: 70)),
    );

    try {
      final user = Provider.of<User>(context, listen: false);

      final success = await user.update_details(
        age ?? 0,
        _phoneController.text.trim(),
        _jobController.text.trim(),
        _addressController.text.trim(),
        _familyStatusController.text.trim(),
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loader

      if (success) {
        showStyledSnackBar(context,
            message: 'تم تحديث البيانات بنجاح 🎉', isError: false);
        Navigator.pop(context); // Go back to profile screen
      } else {
        showStyledSnackBar(context,
            message: 'فشل تحديث البيانات ❌', isError: true);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loader on error
      showStyledSnackBar(context, message: 'حدث خطأ: $e', isError: true);
    }
  }
}