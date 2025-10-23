import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/chapters.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class UserTestEditorForm extends StatefulWidget {
  final TestUserAccepters initialUserInfo;
  final bool canEditParts;
  final bool canEditRating;
  final bool canEditNotes;

  const UserTestEditorForm({
    super.key,
    required this.initialUserInfo,
    this.canEditParts = true,
    this.canEditRating = true,
    this.canEditNotes = true,
  });

  @override
  State<UserTestEditorForm> createState() => _UserTestEditorFormState();
}

class _UserTestEditorFormState extends State<UserTestEditorForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ChaptersState> _chaptersKey = GlobalKey<ChaptersState>();

  late TextEditingController _ratingController;
  late TextEditingController _notesController;
  late List<int> _selectedChapters;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    final info = widget.initialUserInfo;
    _ratingController = TextEditingController(text: info.rating);
    _notesController = TextEditingController(text: info.notes);

    // 🟢 اجزاء الحفظ المبدئية
    _selectedChapters = info.the_part_to_test_in
        .replaceAll(RegExp(r'[\[\] ]'), '')
        .split(',')
        .where((s) => int.tryParse(s) != null)
        .map(int.parse)
        .toList();
  }

  @override
  void dispose() {
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // 🟢 فاليداشن إضافي للأجزاء
    final chaptersState = _chaptersKey.currentState as ChaptersState;
    final selected = chaptersState.get_chapters();
    if (selected.isEmpty) {
      showStyledSnackBar(context,
          message: "يجب اختيار جزء واحد على الأقل", isError: true);
      return;
    }

    setState(() => _isBusy = true);

    try {
      final profile = Provider.of<Profile>(context, listen: false);

      final success = await profile.update_aukaf_tests_after_the_test(
        widget.initialUserInfo.test_id,
        widget.initialUserInfo.user_id,
        selected,
        _ratingController.text,
        _notesController.text,
      );

      if (!mounted) return;

      if (success) {
        showStyledSnackBar(context, message: "تم تعديل البيانات بنجاح");
      } else {
        showStyledSnackBar(context,
            message: "فشل التعديل لسبب غير معروف", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showStyledSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  String? _ratingValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    final num? rating = num.tryParse(value);
    if (rating == null) return 'يجب إدخال رقم صحيح';
    if (rating < 0 || rating > 100) return 'يجب أن يكون بين 0 و 100';
    return null;
  }

  String? _notesValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool number,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters:
          number ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: Colors.grey.shade600),
                title: const Text("اسم الطالب"),
                subtitle: Text(
                  widget.initialUserInfo.user_name,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              if (widget.canEditParts)
                Chapters(
                  key: _chaptersKey,
                  initialSelected: _selectedChapters,
                ),
              if (widget.canEditRating) ...[
                const SizedBox(height: 15),
                _buildTextField(
                  number: true,
                  controller: _ratingController,
                  label: 'التقييم',
                  icon: Icons.rate_review_outlined,
                  validator: _ratingValidator,
                ),
              ],
              if (widget.canEditNotes) ...[
                const SizedBox(height: 15),
                _buildTextField(
                  number: false,
                  controller: _notesController,
                  label: 'الملاحظات',
                  icon: Icons.note_add_outlined,
                  validator: _notesValidator,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isBusy ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: ModernLoader(
                            color: Colors.white,))
                    : const Text('حفظ التعديلات',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
