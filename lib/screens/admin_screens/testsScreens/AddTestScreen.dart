import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class AddTestsScreen extends StatefulWidget {
  final int? originalTestId;

  const AddTestsScreen({super.key, this.originalTestId});

  @override
  State<AddTestsScreen> createState() => _AddTestsScreenState();
}

class _AddTestsScreenState extends State<AddTestsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String notesToAukafTest = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  bool isAukaf = false;

  @override
  void initState() {
    super.initState();
    if (widget.originalTestId != null) {
      isAukaf = true;
    }
  }

  String? _noteValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل الملاحظات';
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      helpText: 'إضافة موعد للسبر',
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) => _customPickerTheme(context, child),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      helpText: 'إضافة موعد للسبر',
      initialTime: selectedTime,
      builder: (context, child) => _customPickerTheme(context, child),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Theme _customPickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.green,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.green),
        ),
      ),
      child: child!,
    );
  }
  
  // ✅ دالة الإرسال المعدلة
  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    formState.save();

    final parsingDate =
        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day} '
        '${selectedTime.hour}:${selectedTime.minute}';

    setState(() => _isLoading = true);

    try {
      final profile = Provider.of<Profile>(context, listen: false);
      bool ok;

      if (widget.originalTestId != null) {
        // منطق إنشاء سبر أوقاف يبقى كما هو
        ok = await profile.make_aukaf_test_for_success_students(
          widget.originalTestId!,
          parsingDate,
          notesToAukafTest,
        );
      } else {
        // جلب daoraId قبل استدعاء الدالة
        final daoraId =
            Provider.of<Daorastate>(context, listen: false).currentDaoraId!;
        ok = await profile.add_new_test(
          parsingDate,
          notesToAukafTest,
          isAukaf,
          daoraId,
        );
      }
      
      if (!mounted) return;

      if (ok) {
        showStyledSnackBar(context, message: 'تم إنشاء السبر بنجاح ✅');
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      // عرض رسالة الخطأ الدقيقة القادمة من الـ Provider
      showStyledSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

@override
Widget build(BuildContext context) {
  // 👇 الخطوة 1: أضف ويدجت Scaffold هنا
  return Scaffold(
    // 👇 الخطوة 2 (اختياري ولكن موصى به): أضف AppBar لعنوان واضح وزر رجوع تلقائي
    appBar: AppBar(
      title: Text(
        widget.originalTestId != null
            ? 'إنشاء سبر أوقاف'
            : 'إضافة سبر ترشيحي',
      style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold), ),
      backgroundColor: Colors.green, // يمكنك تخصيص اللون
    ),
    // 👇 الخطوة 3: ضع الكود القديم بالكامل داخل خاصية الـ body
    body: Consumer<Profile>(
      builder: (context, profile, _) {
        // يبقى هذا الجزء كما هو بدون تغيير
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  // ... باقي محتوى الـ Card يبقى كما هو
                  children: [
                    _buildInfoRow(
                      label: "التاريخ:",
                      value:
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                      onPressed: () => _selectDate(context),
                      buttonLabel: "اختر تاريخ",
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      label: "الوقت:",
                      value:
                          "${selectedTime.hour.toString().padLeft(2, '0')} : ${selectedTime.minute.toString().padLeft(2, '0')}",
                      onPressed: () => _selectTime(context),
                      buttonLabel: "اختر الوقت",
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      validator: _noteValidator,
                      onSaved: (value) =>
                          notesToAukafTest = value?.trim() ?? '',
                      decoration: InputDecoration(
                        labelText: 'ملاحظات',
                        hintText: 'أدخل الملاحظات هنا',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon:
                            const Icon(Icons.note_add, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'نوع السبر:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.originalTestId != null)
                      const Align(
                        alignment: Alignment.center,
                        child: Chip(
                          label: Text('سبر أوقاف للطلاب الناجحين',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.green,
                          avatar: Icon(Icons.check_circle, color: Colors.white),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                      )
                    else
                      const Align(
                        alignment: Alignment.center,
                        child: Chip(
                          label: Text('سبر ترشيحي',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.blueGrey,
                          avatar: Icon(Icons.school, color: Colors.white),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: ModernLoader(size: 20))
                            : Text(
                                widget.originalTestId != null
                                    ? 'إنشاء سبر الأوقاف'
                                    : 'إضافة سبر ترشيحي',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

 Widget _buildInfoRow({
    required String label,
    required String value,
    required VoidCallback onPressed,
    required String buttonLabel,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}