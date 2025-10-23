import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ استيراد sizeConfig
import 'package:masjed/models/objects.dart';

class AddHadith extends StatefulWidget {
  final endedSurahToSend? hadithForForm;
  final GlobalKey<FormState> formKey; // ✅ تم تعديل النوع
  const AddHadith({super.key, this.hadithForForm, required this.formKey});

  @override
  State<AddHadith> createState() => _AddHadithState();
}

class _AddHadithState extends State<AddHadith> {
  // ❌ late TextEditingController fromController;
  // ❌ late TextEditingController toController;
  late TextEditingController markController;
  late TextEditingController pointController;

  // ✅ استخدام عناوين الأحاديث لسهولة البحث والاختيار
  final TextEditingController hadithController = TextEditingController();
  String hadithValue = Quraansoarmanage.AhadithTitles.first;

  // ✅ متغير لتتبع حالة حقل النقاط
  bool _isPointFieldEnabled = true;

  void _updateModel() {
    if (widget.hadithForForm == null) return;
    // ✅ num الآن هو فهرس الحديث في قائمة العناوين
    widget.hadithForForm!.num = Quraansoarmanage.AhadithTitles.indexOf(hadithValue);
    widget.hadithForForm!.from = 0; // ✅ قيمة ثابتة
    widget.hadithForForm!.to = 0;   // ✅ قيمة ثابتة
    widget.hadithForForm!.mark = int.tryParse(markController.text) ?? 0;
    widget.hadithForForm!.point = int.tryParse(pointController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    final initialHadith = widget.hadithForForm;

    // ❌ fromController = ...
    // ❌ toController = ...
    markController = TextEditingController(
        text: initialHadith?.mark == 0 ? '' : initialHadith?.mark.toString());
    pointController = TextEditingController(
        text: initialHadith?.point == 0 ? '' : initialHadith?.point.toString());

    // ✅ تحديث منطق القيمة الأولية ليتناسب مع الفهرس والعناوين
    hadithValue = (initialHadith != null &&
            initialHadith.num >= 0 &&
            initialHadith.num < Quraansoarmanage.AhadithTitles.length)
        ? Quraansoarmanage.AhadithTitles[initialHadith.num]
        : Quraansoarmanage.AhadithTitles.first;
        
    hadithController.text = hadithValue;

    // ❌ fromController.addListener(_updateModel);
    // ❌ toController.addListener(_updateModel);
    
    // ✅ ربط مستمع التقييم
    markController.addListener(_onMarkChanged);
    pointController.addListener(_updateModel);
    
    // ✅ ضبط الحالة الأولية لحقل النقاط
    _updatePointsFieldState();
  }

  @override
  void dispose() {
    // ❌ fromController.removeListener(_updateModel);
    // ❌ toController.removeListener(_updateModel);
    markController.removeListener(_onMarkChanged);
    pointController.removeListener(_updateModel);

    // ❌ fromController.dispose();
    // ❌ toController.dispose();
    markController.dispose();
    pointController.dispose();
    hadithController.dispose();
    super.dispose();
  }

  // ✅ دوال التقييم والنقاط
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

    if (shouldBeEnabled != _isPointFieldEnabled) {
      setState(() {
        _isPointFieldEnabled = shouldBeEnabled;
      });
    }
  }

  // ✅ دوال التحقق
  String? _requiredValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    return null;
  }

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
    // ✅ تهيئة sizeConfig وتعريف أحجام الخطوط
    sizeConfig().init(context);
    final double labelFontSize = sizeConfig.defaultSize! * 1.6;
    final double inputFontSize = sizeConfig.defaultSize! * 1.5;

    const hadithColor = Colors.teal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: hadithColor.withOpacity(0.35),
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
                    "الحديث المسمع:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: labelFontSize),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // ✅ استخدام DropdownMenu للبحث
                    child: DropdownMenu<String>(
                      controller: hadithController,
                      initialSelection: hadithValue,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      hintText: "ابحث عن حديث",
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
                        fillColor: hadithColor.shade50,
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
                            hadithValue = val;
                            _updateModel();
                          });
                        }
                      },
                      // ✅ استخدام AhadithTitles للعرض
                      dropdownMenuEntries: Quraansoarmanage.AhadithTitles
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
                                    hadithColor.shade700),
                                overlayColor: WidgetStateProperty.all(
                                    hadithColor.withOpacity(0.1)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // ❌ صف "من" و "إلى" تم حذفه
              // Row( ... ),
              
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: markController,
                      validator: _markValidator, // ✅ استخدام التحقق
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "التقييم من 100",
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
                      validator: _requiredValidator, // ✅ استخدام التحقق
                      enabled: _isPointFieldEnabled, // ✅ تفعيل/تعطيل
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: "النقاط المستحقة",
                        labelStyle: TextStyle(
                          fontSize: inputFontSize,
                          color: _isPointFieldEnabled
                              ? null
                              : Colors.grey.shade500, // ✅ لون النص المعطل
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        prefixIcon: const Icon(Icons.add_task),
                        filled: true,
                        fillColor: _isPointFieldEnabled
                            ? Colors.grey.shade100
                            : Colors.grey.shade200, // ✅ لون الخلفية المعطل
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