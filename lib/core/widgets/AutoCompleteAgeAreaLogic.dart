import 'package:flutter/material.dart';

class AutocompleteTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> suggestions;
  final Function(String?) onSaved;
  final String? Function(String?) validator;
  final TextEditingController controller;

  const AutocompleteTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.suggestions,
    required this.onSaved,
    required this.validator,
    required this.controller,
  });

  // ✅ دالة لمعالجة النصوص العربية وتوحيدها للمقارنة
  // تزيل الهمزات والتاء المربوطة لتسهيل البحث
  static String _normalizeArabic(String text) {
    text = text.replaceAll('أ', 'ا');
    text = text.replaceAll('إ', 'ا');
    text = text.replaceAll('آ', 'ا');
    text = text.replaceAll('ة', 'ه');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // 1. منشئ الخيارات (هنا يتم فلترة الاقتراحات)
      optionsBuilder: (TextEditingValue textEditingValue) {
        // إذا كان الحقل فارغًا، لا تظهر أي اقتراحات
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        // تحويل النص المدخل إلى نص موحد للبحث
        final normalizedInput = _normalizeArabic(textEditingValue.text.toLowerCase());

        // فلترة القائمة بناءً على النص الموحد
        return suggestions.where((String option) {
          final normalizedOption = _normalizeArabic(option.toLowerCase());
          return normalizedOption.contains(normalizedInput);
        });
      },

      // 2. عند اختيار اقتراح
      onSelected: (String selection) {
        controller.text = selection;
      },

      // 3. بناء حقل الإدخال نفسه (TextFormField)
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // نستخدم نفس الـ controller الذي تم تمريره للـ widget
        // لضمان حفظ القيمة بشكل صحيح
        Future.microtask(() => fieldController.text = controller.text);
        
        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(45)),
            label: Text(label),
            prefixIcon: Icon(icon),
          ),
          validator: validator,
          onSaved: onSaved,
        );
      },

      // 4. بناء قائمة الاقتراحات
optionsViewBuilder: (
  BuildContext context,
  AutocompleteOnSelected<String> onSelected,
  Iterable<String> options,
) {
  final theme = Theme.of(context);

  return Align(
    alignment: Alignment.topLeft,
    child: Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: options.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          itemBuilder: (BuildContext context, int index) {
            final String option = options.elementAt(index);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                child: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
},
    );
  }
}