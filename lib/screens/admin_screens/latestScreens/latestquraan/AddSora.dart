import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ استيراد sizeConfig
import 'package:masjed/models/objects.dart';

class AddSora extends StatefulWidget {
  final endedSurahToSend? sorahForForm;
  final GlobalKey<FormState> formKey; // ✅ تم تعديل النوع إلى GlobalKey

  const AddSora({
    super.key,
    required this.sorahForForm,
    required this.formKey,
  });

  @override
  State<AddSora> createState() => _AddSoraState();
}

class _AddSoraState extends State<AddSora> {
  late TextEditingController fromController;
  late TextEditingController toController;
  late TextEditingController markController;
  late TextEditingController pointController;

  final TextEditingController soraController = TextEditingController();
  String soraValue = Quraansoarmanage.soarList.first;

  // ✅ متغير لتتبع حالة حقل النقاط
  bool _isPointFieldEnabled = true;

  void _updateModel() {
    if (widget.sorahForForm == null) return;
    widget.sorahForForm!.num = Quraansoarmanage.soarList.indexOf(soraValue);
    widget.sorahForForm!.from = int.tryParse(fromController.text) ?? 0;
    widget.sorahForForm!.to = int.tryParse(toController.text) ?? 0;
    widget.sorahForForm!.mark = int.tryParse(markController.text) ?? 0;
    widget.sorahForForm!.point = int.tryParse(pointController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();

    fromController = TextEditingController(
        text: widget.sorahForForm?.from == 0
            ? ''
            : widget.sorahForForm?.from.toString());
    toController = TextEditingController(
        text: widget.sorahForForm?.to == 0
            ? ''
            : widget.sorahForForm?.to.toString());
    markController = TextEditingController(
        text: widget.sorahForForm?.mark == 0
            ? ''
            : widget.sorahForForm?.mark.toString());
    pointController = TextEditingController(
        text: widget.sorahForForm?.point == 0
            ? ''
            : widget.sorahForForm?.point.toString());

    soraValue = widget.sorahForForm != null
        ? Quraansoarmanage.soarList[widget.sorahForForm!.num]
        : Quraansoarmanage.soarList.first;

    soraController.text = soraValue;

    fromController.addListener(_updateModel);
    toController.addListener(_updateModel);
    // ✅ ربط مستمع التقييم بالدالة الجديدة
    markController.addListener(_onMarkChanged);
    pointController.addListener(_updateModel);

    // ✅ ضبط الحالة الأولية لحقل النقاط
    _updatePointsFieldState();
  }

  @override
  void dispose() {
    fromController.removeListener(_updateModel);
    toController.removeListener(_updateModel);
    // ✅ إزالة المستمع عند الخروج
    markController.removeListener(_onMarkChanged);
    pointController.removeListener(_updateModel);

    fromController.dispose();
    toController.dispose();
    markController.dispose();
    pointController.dispose();
    soraController.dispose();
    super.dispose();
  }

  // ✅ دالة تحديث النقاط بناءً على التقييم
  void _onMarkChanged() {
    _updatePointsFieldState();
    _updateModel(); // تأكد من تحديث النموذج
  }

  void _updatePointsFieldState() {
    final mark = int.tryParse(markController.text) ?? 0;
    bool shouldBeEnabled = true;

    if (mark < 80) {
      pointController.text = '0'; // تصفير النقاط
      shouldBeEnabled = false; // تعطيل الحقل
    }

    // ✅ تحديث الحالة فقط إذا تغيرت لتجنب إعادة البناء غير الضرورية
    if (shouldBeEnabled != _isPointFieldEnabled) {
      setState(() {
        _isPointFieldEnabled = shouldBeEnabled;
      });
    }
  }

  // ✅ دالة التحقق للحقول المطلوبة
  String? _requiredValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    return null;
  }

  // ✅ دالة التحقق لحقل "من الآية"
  String? _fromValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    final fromAyah = int.tryParse(v);
    if (fromAyah == null) return "رقم غير صالح";
    if (fromAyah < 1) return "لا يمكن أن يقل عن 1";


    return null;
  }

  // ✅ دالة التحقق لحقل "إلى الآية"
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

  // ✅ دالة التحقق لحقل "التقييم"
  String? _markValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    final mark = int.tryParse(v);
    if (mark == null) return "رقم غير صالح";
    if (mark > 100) return "لا يمكن أن يزيد عن 100";
    if (mark < 0) return "لا يمكن أن يقل عن 0";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تهيئة sizeConfig
    sizeConfig().init(context);
    // ✅ تعريف أحجام خطوط متجاوبة
    final double labelFontSize = sizeConfig.defaultSize! * 1.6;
    final double inputFontSize = sizeConfig.defaultSize! * 1.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Form(
          key: widget.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "السورة المسمعة:",
                    // ✅ استخدام حجم خط متجاوب
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: labelFontSize),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownMenu<String>(
                      controller: soraController,
                      initialSelection: soraValue,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      hintText: "ابحث عن سورة",
                      // ✅ استخدام حجم خط متجاوب
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
                        fillColor: Colors.green.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      // ... ( باقي خصائص DropdownMenu كما هي )
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        elevation: WidgetStateProperty.all(8), // الظل
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
                            _updateModel();

                            // ✅ إعادة التحقق من الحقول عند تغيير السورة
                            // نستخدم تأخير بسيط لضمان تحديث soraValue قبل التحقق
                            Future.delayed(const Duration(milliseconds: 50), () {
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
                                  // ✅ استخدام حجم خط متجاوب
                                  TextStyle(
                                      fontSize: inputFontSize,
                                      fontWeight: FontWeight.w500),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                    Colors.green.shade700),
                                overlayColor: WidgetStateProperty.all(
                                    Colors.green.withOpacity(0.1)), // عند الضغط
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: markController,
                      // ✅ استخدام دالة التحقق الجديدة
                      validator: _markValidator,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "التقييم من 100",
                        // ✅ استخدام حجم خط متجاوب للعنوان
                        labelStyle: TextStyle(fontSize: inputFontSize),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: const Icon(Icons.star_half),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: pointController,
                      // ✅ استخدام دالة التحقق البسيطة
                      validator: _requiredValidator,
                      // ✅ تفعيل/تعطيل الحقل بناءً على الحالة
                      enabled: _isPointFieldEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "النقاط المستحقة",
                        // ✅ استخدام حجم خط متجاوب للعنوان
                        labelStyle: TextStyle(
                          fontSize: inputFontSize,
                          // ✅ تغيير اللون إذا كان الحقل معطلاً
                          color: _isPointFieldEnabled
                              ? null
                              : Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: const Icon(Icons.add_task),
                        filled: true,
                        // ✅ تغيير لون الخلفية إذا كان الحقل معطلاً
                        fillColor: _isPointFieldEnabled
                            ? Colors.grey.shade100
                            : Colors.grey.shade200,
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