import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/ActCard.dart';
import 'package:masjed/state/offline.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class LatestActivity extends StatefulWidget {
  final int userId;
  const LatestActivity({super.key, required this.userId});

  @override
  State<LatestActivity> createState() => _LatestActivityState();
}

class _LatestActivityState extends State<LatestActivity> {
  final List<activitiesToSend> theActivitiesToSendToProfile = [];
  final List<GlobalKey<FormState>> _activityFormKeys = [];
  bool _isLoading = false;

  // ✅ إنشاء كائن من خدمة المزامنة
  final OfflineSyncService offlineService = OfflineSyncService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndSync();
    });
  }

  // ✅ دالة لمزامنة البيانات المحفوظة عند فتح الشاشة
  Future<void> _initializeAndSync() async {
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    if (isOnline) {
      final user = context.read<User>();
      final success = await offlineService.sendPendingActivitySubmissions(user);
      if (!mounted) return;
      if (success) {
        showStyledSnackBar(context, message: 'تمت مزامنة بيانات الأنشطة المحفوظة');
      } else {
        showStyledSnackBar(context, message: 'فشل مزامنة بعض بيانات الأنشطة', isError: true);
      }
    }
  }

  void _addActivity() {
    setState(() {
      theActivitiesToSendToProfile.add(activitiesToSend(name: "", mark: 0, point: 0));
      _activityFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeActivity() {
    setState(() {
      if (theActivitiesToSendToProfile.isNotEmpty) {
        theActivitiesToSendToProfile.removeLast();
        _activityFormKeys.removeLast();
      }
    });
  }

  void _resetState() {
    setState(() {
      theActivitiesToSendToProfile.clear();
      _activityFormKeys.clear();
    });
  }

  // ✅ دالة الإرسال المُعدّلة بالكامل
  Future<void> submit() async {
    if (theActivitiesToSendToProfile.isEmpty) {
      showStyledSnackBar(context, message: 'لا توجد بيانات للإرسال', isError: true);
      return;
    }

    bool allValid = true;
    for (var key in _activityFormKeys) {
      allValid &= key.currentState?.validate() ?? false;
    }

    if (!allValid) {
      showStyledSnackBar(context, message: 'الرجاء ملء جميع الحقول المطلوبة', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    for (var key in _activityFormKeys) {
      key.currentState?.save();
    }

    User user = Provider.of<User>(context, listen: false);
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    
    List<Map<String, dynamic>> payload = theActivitiesToSendToProfile.map((e) => e.toJson()).toList();

    if (isOnline) {
      // ===== الكود في حالة الاتصال بالإنترنت =====
      try {
        final bool success = await user.add_latest_activity(widget.userId, payload);
        if (!mounted) return;
        if (success) {
          showStyledSnackBar(context, message: 'تم إضافة النشاطات بنجاح', isError: false);
          _resetState();
        } else {
          showStyledSnackBar(context, message: 'حدثت مشكلة في الإضافة', isError: true);
        }
      } catch (e) {
        if (!mounted) return;
        showStyledSnackBar(context, message: e.toString(), isError: true);
      }
    } else {
      // ===== الكود في حالة عدم الاتصال بالإنترنت =====
      final submission = {
        'userId': widget.userId,
        'payload': payload,
        'type': 'activity',
      };
      
      try {
        await offlineService.saveActivitySubmissionToCache(submission);
        Workmanager().registerOneOffTask(
          "activitySyncTask-${DateTime.now().millisecondsSinceEpoch}",
          "syncAllPendingData",
          constraints: Constraints(networkType: NetworkType.connected),
        );
        if (mounted) {
          showStyledSnackBar(context, message: 'تم الحفظ محلياً، سيتم الإرسال عند توفر الإنترنت');
          _resetState();
        }
      } catch (e) {
         if (mounted) showStyledSnackBar(context, message: 'فشل حفظ البيانات محلياً', isError: true);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ... (دوال الواجهة build و _buildSection تبقى كما هي)
  @override

  Widget _buildSection({
    required String title,
    required List<activitiesToSend> items,
    required List<GlobalKey<FormState>> formKeys,
    required Widget Function(
            activitiesToSend item, int index, GlobalKey<FormState> formKey)
        buildCard,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required IconData sectionIcon,
    required Color sectionColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: sectionColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(sectionIcon, color: sectionColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: sectionColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.8),
            ...items.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: buildCard(entry.value, entry.key, formKeys[entry.key]),
              );
            }),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: onAdd,
                    icon: Icon(Icons.add_circle,
                        color: Colors.teal.shade700, size: 28)),
                IconButton(
                    onPressed: onRemove,
                    icon: Icon(Icons.remove_circle,
                        color: Colors.red.shade400, size: 28)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildSection(
                title: "الأنشطة",
                items: theActivitiesToSendToProfile,
                formKeys: _activityFormKeys,
                buildCard: (item, index, formKey) =>
                    ActCard(activityForForm: item, formKey: formKey),
                onAdd: _addActivity,
                onRemove: _removeActivity,
                sectionIcon: Icons.event_note_outlined,
                sectionColor: const Color.fromARGB(255, 35, 122, 25),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoading
              ? const ModernLoader(
                  size: 20,
                )
              : SubmitFormButton(submit: submit),
        ),
      ],
    );
  }
}
