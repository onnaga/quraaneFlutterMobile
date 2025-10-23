import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class actionsForUsersWithTests extends StatefulWidget {
  final int aukaf;
  final String date;
  final int test_id;
  const actionsForUsersWithTests(
      {super.key,
      required this.aukaf,
      required this.date,
      required this.test_id});

  @override
  State<actionsForUsersWithTests> createState() => _actionsForUsersWithTestsState();
}

class _actionsForUsersWithTestsState extends State<actionsForUsersWithTests> {
  bool _loading = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadRegistrationStatus();
  }

  Future<void> _loadRegistrationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> registeredTests =
        prefs.getStringList("registered_tests") ?? [];
    setState(() {
      _isRegistered = registeredTests.contains(widget.test_id.toString());
    });
  }

  Future<void> _updateRegisteredTests(bool add) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> registeredTests =
        prefs.getStringList("registered_tests") ?? [];

    if (add) {
      if (!registeredTests.contains(widget.test_id.toString())) {
        registeredTests.add(widget.test_id.toString());
      }
    } else {
      registeredTests.remove(widget.test_id.toString());
    }

    await prefs.setStringList("registered_tests", registeredTests);
    setState(() {
      _isRegistered = add;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canApply = widget.aukaf != 1 &&
        DateTime.now().isBefore(DateTime.parse(widget.date));

    if (!canApply) {
      return const SizedBox.shrink();
    }


    // أزلنا اللودر الخارجي كي يظهر داخل الزر فقط

    if (_isRegistered) {
      // زر حذف التسجيل
      return _buildUserButton(
  text: 'حذف التقديم',
  color: const Color.fromARGB(255, 240, 30, 15),
  onPressed: _loading
      ? null
      : () async {
          setState(() => _loading = true);
          
          try {
            final profile = Provider.of<Profile>(context, listen: false);
            // استدعاء الدالة بدون context
            await profile.delete_accepted_test(widget.test_id);

            if (!mounted) return;

            showStyledSnackBar(context, message: 'تم حذف التقديم');
            // استدعاء دالة تحديث الحالة
            await _updateRegisteredTests(false);

          } catch (e) {
            if (!mounted) return;
            showStyledSnackBar(context, message: e.toString(), isError: true);
          } finally {
            if (mounted) {
              setState(() => _loading = false);
            }
          }
        },
); }
     else {
      // زر تقديم للسبر
      return _buildUserButton(
        text: 'تقديم للسبر',
        color: const Color.fromARGB(255, 31, 100, 173),
  onPressed: _loading
    ? null
    : () async {
        setState(() => _loading = true);
        
        try {
          final profile = Provider.of<Profile>(context, listen: false);
          // استدعاء الدالة بدون context
          await profile.accept_test(widget.test_id);

          if (!mounted) return;

          showStyledSnackBar(context, message: 'تم التقديم بنجاح');
          // استدعاء دالة تحديث الحالة
          await _updateRegisteredTests(true);
        
        } catch (e) {
          if (!mounted) return;
          showStyledSnackBar(context, message: e.toString(), isError: true);
        } finally {
          if (mounted) {
            setState(() => _loading = false);
          }
        }
      },);
    }
  }

  Widget _buildUserButton(
      {required String text,
      required Color color,
      required VoidCallback? onPressed}) {
    return SizedBox(
      width: sizeConfig.defaultSize! * 16,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          side: BorderSide.none,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _loading
              ? const SizedBox(
                  key: ValueKey('loader'),
                  height: 20,
                  width: 20,
                  child: ModernLoader(size: 20),
                )
              : Text(
                  text,
                  key: const ValueKey('text'),
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }

}