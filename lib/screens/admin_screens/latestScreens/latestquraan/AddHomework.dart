import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ استيراد sizeConfig
import 'package:masjed/models/objects.dart';

class AddHomework extends StatefulWidget {
  final homeworkSurahToSend? homeworkForForm;
  final GlobalKey<FormState> formKey;

  const AddHomework({
    super.key,
    this.homeworkForForm,
    required this.formKey,
  });

  @override
  State<AddHomework> createState() => _AddHomeworkState();
}

class _AddHomeworkState extends State<AddHomework> {
  late TextEditingController fromController;
  late TextEditingController toController;

  // ✅ لإدارة القائمة المنسدلة القابلة للبحث
  final TextEditingController soraController = TextEditingController();
  String soraValue = Quraansoarmanage.soarList.first;

  // 🆕 متغير لحالة "السورة كاملة"
  bool _isFullSurah = false;
  // 🆕 متغير لمنع المستمعات من العمل أثناء التحديث البرمجي
  bool _isUpdatingAyatProgrammatically = false;

  void _updateModel() {
    if (widget.homeworkForForm == null) return;
    widget.homeworkForForm!.num = Quraansoarmanage.soarList.indexOf(soraValue);
    widget.homeworkForForm!.from = int.tryParse(fromController.text) ?? 0;
    widget.homeworkForForm!.to = int.tryParse(toController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();

    fromController = TextEditingController(
        text: widget.homeworkForForm?.from == 0
            ? ''
            : widget.homeworkForForm?.from.toString());
    toController = TextEditingController(
        text: widget.homeworkForForm?.to == 0
            ? ''
            : widget.homeworkForForm?.to.toString());

    soraValue = widget.homeworkForForm != null
        ? Quraansoarmanage.soarList[widget.homeworkForForm!.num]
        : Quraansoarmanage.soarList.first;

    // ✅ تهيئة المتحكم
    soraController.text = soraValue;

    // 🆕 ربط المستمعات بالدوال الجديدة للتحكم بالـ Checkbox
    fromController.addListener(_onFromAyahChanged);
    toController.addListener(_onToAyahChanged);

    // 🆕 تحقق من الحالة الأولية لحقول الآيات لمطابقتها مع "السورة كاملة"
    _checkInitialFullSurahState();
  }

  @override
  void dispose() {
    // 🆕 إزالة المستمعات الجديدة
    fromController.removeListener(_onFromAyahChanged);
    toController.removeListener(_onToAyahChanged);

    fromController.dispose();
    toController.dispose();
    // ✅ التخلص من المتحكم
    soraController.dispose();
    super.dispose();
  }

  // 🆕 دالة للتحقق من الحالة الأولية (عند فتح الفورم للتعديل مثلاً)
  void _checkInitialFullSurahState() {
    if (widget.homeworkForForm?.from == 1) {
      final maxAyat = Quraansoarmanage.ayatCount[soraValue] ?? 0;
      if (maxAyat > 0 && widget.homeworkForForm?.to == maxAyat) {
        setState(() {
          _isFullSurah = true;
        });
      }
    }
  }

  // 🆕 دوال المستمعات الجديدة لحقول "من/إلى"
  void _onFromAyahChanged() {
    if (_isUpdatingAyatProgrammatically) return;
    _uncheckFullSurahOnManualEdit();
    _updateModel();
  }

  void _onToAyahChanged() {
    if (_isUpdatingAyatProgrammatically) return;
    _uncheckFullSurahOnManualEdit();
    _updateModel();
  }

  // 🆕 دالة لإلغاء تحديد "السورة كاملة" عند التغيير اليدوي
  void _uncheckFullSurahOnManualEdit() {
    if (_isFullSurah) {
      final maxAyat = Quraansoarmanage.ayatCount[soraValue] ?? 0;
      final bool matchesFullSurah = (fromController.text == "1" &&
          toController.text == (maxAyat > 0 ? maxAyat.toString() : ""));

      if (!matchesFullSurah) {
        setState(() {
          _isFullSurah = false;
        });
      }
    }
  }

  // 🆕 دالة لتحديث الحقول عند ضغط "السورة كاملة"
  void _toggleFullSurah(bool? newValue) {
    if (newValue == null) return;

    setState(() {
      _isFullSurah = newValue;
      _isUpdatingAyatProgrammatically = true; // 🆕 منع المستمعات

      if (_isFullSurah) {
        // إذا تم التحديد: املأ الحقول
        final maxAyat = Quraansoarmanage.ayatCount[soraValue] ?? 0;
        fromController.text = "1";
        toController.text = maxAyat > 0 ? maxAyat.toString() : "";
      } else {
        // إذا تم إلغاء التحديد: أفرغ الحقول
        fromController.text = "";
        toController.text = "";
      }

      _isUpdatingAyatProgrammatically = false; // 🆕 السماح للمستمعات
      _updateModel(); // تحديث النموذج

      // إعادة التحقق لإظهار الأخطاء أو إخفائها فوراً
      Future.delayed(const Duration(milliseconds: 50), () {
        widget.formKey.currentState?.validate();
      });
    });
  }

  // ✅ دوال التحقق الجديدة
  String? _fromValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    final fromAyah = int.tryParse(v);
    if (fromAyah == null) return "رقم غير صالح";
    if (fromAyah < 1) return "لا يمكن أن يقل عن 1";

    return null;
  }

  String? _toValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    final toAyah = int.tryParse(v);
    if (toAyah == null) return "رقم غير صالح";

    final maxAyat = Quraansoarmanage.ayatCount[soraValue] ?? 0;
    if (maxAyat > 0 && toAyah > maxAyat) {
      return "أكبر من عدد آيات السورة ($maxAyat)";
    }

    final fromAyah = int.tryParse(fromController.text);
    if (fromAyah != null && toAyah < fromAyah) {
      return "يجب أن يكون أكبر من 'من الآية'";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تهيئة sizeConfig
    sizeConfig().init(context);
    // ✅ تعريف أحجام خطوط متجاوبة
    final double labelFontSize = sizeConfig.defaultSize! * 1.6;
    final double inputFontSize = sizeConfig.defaultSize! * 1.5;

    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.35),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "السورة المطلوبة:",
                    // ✅ استخدام حجم خط متجاوب
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: labelFontSize),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // ✅ استخدام DropdownMenu للبحث
                    child: DropdownMenu<String>(
                      controller: soraController,
                      initialSelection: soraValue,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      hintText: "ابحث عن سورة",
                      textStyle: TextStyle(
                        fontSize: inputFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50, // تغيير اللون ليتناسب
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        elevation: WidgetStateProperty.all(8),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                      onSelected: (val) {
                        if (val != null) {
                          setState(() {
                            soraValue = val;
                            // _updateModel(); // 🆕 تم نقلها للأسفل

                            // 🆕 تحديث الحقول إذا كان "السورة كاملة" محدداً
                            if (_isFullSurah) {
                              _isUpdatingAyatProgrammatically = true;
                              final maxAyat =
                                  Quraansoarmanage.ayatCount[soraValue] ?? 0;
                              fromController.text = "1";
                              toController.text =
                                  maxAyat > 0 ? maxAyat.toString() : "";
                              _isUpdatingAyatProgrammatically = false;
                            }

                            _updateModel(); // 🆕 تحديث النموذج بعد كل التغييرات

                            // ✅ إعادة التحقق من الحقول عند تغيير السورة
                            Future.delayed(const Duration(milliseconds: 50),
                                () {
                              widget.formKey.currentState?.validate();
                            });
                          });
                        }
                      },
                      dropdownMenuEntries: Quraansoarmanage.soarList
                          .map(
                            (e) => DropdownMenuEntry(
                              value: e,
                              label: e,
                              style: ButtonStyle(
                                textStyle: WidgetStateProperty.all(
                                  TextStyle(
                                      fontSize: inputFontSize,
                                      fontWeight: FontWeight.w500),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                    Colors.blue.shade700), // تغيير اللون
                                overlayColor: WidgetStateProperty.all(
                                    Colors.blue.withOpacity(0.1)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 18), // 🆕 تم تعديل المسافة

              // 🆕 إضافة CheckboxListTile
              CheckboxListTile(
                title: Text(
                  "السورة كاملة",
                  style: TextStyle(
                      fontSize: labelFontSize * 0.95,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                value: _isFullSurah,
                onChanged: _toggleFullSurah,
                activeColor: Colors.blue, // 🆕 مطابقة اللون الأزرق
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                dense: true,
              ),
              // 🆕 تم تعديل المسافة لتكون بعد الـ Checkbox
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fromController,
                      // ✅ استخدام دالة التحقق الجديدة
                      validator: _fromValidator,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "من الآية",
                        // ✅ استخدام حجم خط متجاوب للعنوان
                        labelStyle: TextStyle(fontSize: inputFontSize),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: const Icon(Icons.format_list_numbered),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: toController,
                      // ✅ استخدام دالة التحقق الجديدة
                      validator: _toValidator,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "إلى الآية",
                        // ✅ استخدام حجم خط متجاوب للعنوان
                        labelStyle: TextStyle(fontSize: inputFontSize),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon:
                            const Icon(Icons.format_list_numbered_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}