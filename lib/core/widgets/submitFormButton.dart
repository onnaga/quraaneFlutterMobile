import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/modern_loader.dart';

class SubmitFormButton extends StatefulWidget {
  final Future<void> Function() submit;

  const SubmitFormButton({
    super.key,
    required this.submit,
  });

  @override
  State<SubmitFormButton> createState() => _SubmitFormButtonState();
}

class _SubmitFormButtonState extends State<SubmitFormButton> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final start = DateTime.now();

    try {
      await widget.submit(); // صار async لتفادي مشاكل المستقبل
    } finally {
      // ضمان أن اللودر يظهر على الأقل 0.5 ثانية
      final elapsed = DateTime.now().difference(start);
      final wait = elapsed.inMilliseconds < 500
          ? 500 - elapsed.inMilliseconds
          : 0;

      await Future.delayed(Duration(milliseconds: wait));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  height: 32,
                  width: 32,
                  child: ModernLoader(size: 32), // اللودر الجديد
                )
              : const Text(
                  key: ValueKey('text'),
                  'إضافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
