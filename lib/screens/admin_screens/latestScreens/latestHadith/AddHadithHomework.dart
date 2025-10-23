import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart'; // ✅ استيراد sizeConfig
import 'package:masjed/models/objects.dart';

class AddHadithHomework extends StatefulWidget {
  final homeworkSurahToSend? homeworkForForm;
  final GlobalKey<FormState> formKey; // ✅ تم تعديل النوع
  const AddHadithHomework(
      {super.key, this.homeworkForForm, required this.formKey});

  @override
  State<AddHadithHomework> createState() => _AddHadithHomeworkState();
}

class _AddHadithHomeworkState extends State<AddHadithHomework> {
  // ❌ late TextEditingController fromController;
  // ❌ late TextEditingController toController;

  // ✅ استخدام عناوين الأحاديث لسهولة البحث والاختيار
  final TextEditingController hadithController = TextEditingController();
  String hadithValue = Quraansoarmanage.AhadithTitles.first;


  void _updateModel() {
    if (widget.homeworkForForm == null) return;
    // ✅ num الآن هو فهرس الحديث في قائمة العناوين
    widget.homeworkForForm!.num = Quraansoarmanage.AhadithTitles.indexOf(hadithValue);
    widget.homeworkForForm!.from = 0; // ✅ قيمة ثابتة
    widget.homeworkForForm!.to = 0;   // ✅ قيمة ثابتة
  }

  @override
  void initState() {
    super.initState();

    final initialHomework = widget.homeworkForForm;

    // ❌ fromController = ...
    // ❌ toController = ...

    // ✅ تحديث منطق القيمة الأولية ليتناسب مع الفهرس والعناوين
    hadithValue = (initialHomework != null &&
            initialHomework.num >= 0 &&
            initialHomework.num < Quraansoarmanage.AhadithTitles.length)
        ? Quraansoarmanage.AhadithTitles[initialHomework.num]
        : Quraansoarmanage.AhadithTitles.first;
        
    hadithController.text = hadithValue;

    // ❌ fromController.addListener(_updateModel);
    // ❌ toController.addListener(_updateModel);
  }

  @override
  void dispose() {
    // ❌ fromController.removeListener(_updateModel);
    // ❌ toController.removeListener(_updateModel);

    // ❌ fromController.dispose();
    // ❌ toController.dispose();
    hadithController.dispose();
    super.dispose();
  }

  // ❌ _validator ليس مطلوباً إذا لم تكن هناك حقول TextFormField أخرى

  @override
  Widget build(BuildContext context) {
    // ✅ تهيئة sizeConfig وتعريف أحجام الخطوط
    sizeConfig().init(context);
    final double labelFontSize = sizeConfig.defaultSize! * 1.6;
    final double inputFontSize = sizeConfig.defaultSize! * 1.5;

    const homeworkColor = Colors.blue;

    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: homeworkColor.withOpacity(0.35),
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
                    "الحديث المطلوب:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: labelFontSize),
                    textDirection: TextDirection.rtl,
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
                        fillColor: homeworkColor.shade50,
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
                                    homeworkColor.shade700),
                                overlayColor: WidgetStateProperty.all(
                                    homeworkColor.withOpacity(0.1)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              
              // ❌ صف "من" و "إلى" تم حذفه
              // const SizedBox(height: 18),
              // Row( ... ),
              
            ],
          ),
        ),
      ),
    );
  }
}