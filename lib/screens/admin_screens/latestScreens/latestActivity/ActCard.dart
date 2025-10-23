import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/models/objects.dart';

class ActCard extends StatefulWidget {
  final activitiesToSend? activityForForm;
  final GlobalKey<FormState> formKey; // ✅ استخدم نوع GlobalKey<FormState>

  const ActCard({super.key, this.activityForForm, required this.formKey});

  @override
  State<ActCard> createState() => _ActCardState();
}

class _ActCardState extends State<ActCard> {
  late TextEditingController nameController;
  late TextEditingController markController;
  late TextEditingController pointController;

  // ✅ متغير لتتبع حالة حقل النقاط
  bool _isPointFieldEnabled = true;

  void _updateModel() {
    if (widget.activityForForm == null) return;
    widget.activityForForm!.name = nameController.text;
    widget.activityForForm!.mark = int.tryParse(markController.text) ?? 0;
    widget.activityForForm!.point = int.tryParse(pointController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    final initActivity = widget.activityForForm;

    nameController = TextEditingController(text: initActivity?.name ?? '');
    markController = TextEditingController(
        text: initActivity?.mark == 0 ? '' : initActivity?.mark.toString());
    pointController = TextEditingController(
        text: initActivity?.point == 0 ? '' : initActivity?.point.toString());

    nameController.addListener(_updateModel);
    // ✅ تغيير المستمع الخاص بالتقييم
    markController.addListener(_onMarkChanged);
    pointController.addListener(_updateModel);

    // ✅ ضبط الحالة الأولية لحقل النقاط
    _updatePointsFieldState();
  }

  @override
  void dispose() {
    nameController.removeListener(_updateModel);
    // ✅ إزالة المستمع الصحيح
    markController.removeListener(_onMarkChanged);
    pointController.removeListener(_updateModel);

    nameController.dispose();
    markController.dispose();
    pointController.dispose();
    super.dispose();
  }

  // ✅ دالة تحديث حالة حقل النقاط
  void _onMarkChanged() {
    _updatePointsFieldState();
    _updateModel(); // تأكد من تحديث النموذج
  }

  // ✅ دالة منطق تفعيل/تعطيل النقاط
  void _updatePointsFieldState() {
    final mark = int.tryParse(markController.text) ?? 0;
    bool shouldBeEnabled = true;

    // ✅ الشرط: يجب أن تكون العلامة أكبر من 80
    if (mark < 80) { // إذا كانت 80 أو أقل
      pointController.text = '0'; // تصفير النقاط
      shouldBeEnabled = false; // تعطيل الحقل
    }

    if (shouldBeEnabled != _isPointFieldEnabled) {
      setState(() {
        _isPointFieldEnabled = shouldBeEnabled;
      });
    }
  }

  String? _markValidator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    final mark = int.tryParse(v);
    if (mark == null) return "رقم غير صالح";
    if (mark > 100) return "لا يمكن أن يزيد عن 100";
    if (mark < 0) return "لا يمكن أن يقل عن 0";
    return null;
  }

  String? _validator(String? v) {
    if (v == null || v.isEmpty) return "هذا الحقل مطلوب";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const actColor = Colors.indigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Form(
        key: widget.formKey, // مهم هنا
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: actColor.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // اسم النشاط
              Row(
                children: [
                  const Text(
                    "اسم النشاط:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      validator: _validator,
                      decoration: InputDecoration(
                        labelText: "اسم النشاط",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.event_note_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // التقييم والنقاط
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: markController,
                      validator: _markValidator,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "التقييم من 100",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.star_rate),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: pointController,
                      validator: _validator,
                      // ✅ ربط حالة التفعيل/التعطيل
                      enabled: _isPointFieldEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "النقاط المكتسبة",
                        // ✅ تغيير لون النص ليعكس حالة التعطيل
                        labelStyle: TextStyle(
                          color: _isPointFieldEnabled
                              ? null
                              : Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.score),
                        filled: true,
                        // ✅ تغيير لون الخلفية ليعكس حالة التعطيل
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