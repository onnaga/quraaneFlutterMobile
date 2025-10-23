import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/AddHadith.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestHadith/AddHadithHomework.dart';
import 'package:masjed/state/offline.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class LatestHadith extends StatefulWidget {
  final int userId;
  const LatestHadith({super.key, required this.userId});

  @override
  State<LatestHadith> createState() => _LatestHadithState();
}

class _LatestHadithState extends State<LatestHadith> {
  final List<endedSurahToSend> theAhadithToSendToProfile = [];
  final List<homeworkSurahToSend> theAhadithHomeworksToSendToProfile = [];
  bool _isLoading = false;
  final List<GlobalKey<FormState>> _hadithFormKeys = [];
  final List<GlobalKey<FormState>> _homeworkFormKeys = [];

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
      final success = await offlineService.sendPendingHadithSubmissions(user);
      if (!mounted) return;
      if (success) {
        showStyledSnackBar(context, message: 'تمت مزامنة بيانات الأحاديث المحفوظة');
      } else {
        showStyledSnackBar(context, message: 'فشل مزامنة بعض بيانات الأحاديث', isError: true);
      }
    }
  }
  
  void _resetState() {
    setState(() {
      theAhadithToSendToProfile.clear();
      theAhadithHomeworksToSendToProfile.clear();
      _hadithFormKeys.clear();
      _homeworkFormKeys.clear();
    });
  }

  // ... (دوال الإضافة والحذف تبقى كما هي)
  void _addHadith() {
    setState(() {
      theAhadithToSendToProfile.add(endedSurahToSend(num: 0, from: 0, to: 0, mark: 0, point: 0));
      _hadithFormKeys.add(GlobalKey<FormState>());
    });
  }


 void _removeHadith() {

setState(() {
if (theAhadithToSendToProfile.isNotEmpty) {
  theAhadithToSendToProfile.removeLast();
  _hadithFormKeys.removeLast();
}
});
 }



void _addHomework() {
  setState(() {
    theAhadithHomeworksToSendToProfile.add(
      homeworkSurahToSend(num: 0, from: 0, to: 0),
    );
    _homeworkFormKeys.add(GlobalKey<FormState>());
  });
}

void _removeHomework() {
  setState(() {
    if (theAhadithHomeworksToSendToProfile.isNotEmpty) {
      theAhadithHomeworksToSendToProfile.removeLast();
      _homeworkFormKeys.removeLast();
    }
  });
}



  // ✅ دالة الإرسال المُعدّلة بالكامل
  Future<void> submit() async {
    if (theAhadithToSendToProfile.isEmpty && theAhadithHomeworksToSendToProfile.isEmpty) {
      showStyledSnackBar(context, message: 'لا توجد بيانات للإرسال', isError: true);
      return;
    }

    bool allValid = true;
    for (var key in _hadithFormKeys) {
      allValid &= key.currentState?.validate() ?? false;
    }
    for (var key in _homeworkFormKeys) {
      allValid &= key.currentState?.validate() ?? false;
    }

    if (!allValid) {
      showStyledSnackBar(context, message: 'الرجاء ملء جميع الحقول المطلوبة', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    for (var key in _hadithFormKeys) {
      key.currentState?.save();
    }
    for (var key in _homeworkFormKeys) {
      key.currentState?.save();
    }

    User user = Provider.of<User>(context, listen: false);
    List<Map<String, dynamic>> ahadithJson = theAhadithToSendToProfile.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> homeworkJson = theAhadithHomeworksToSendToProfile.map((e) => e.toJson()).toList();
    final payload = [ahadithJson, homeworkJson];

    final isOnline = context.read<ConnectivityProvider>().isOnline;

    if (isOnline) {
      // ===== الكود في حالة الاتصال بالإنترنت =====
      try {
        bool success = await user.add_latest_quraan_hadith(widget.userId, payload, false); // false for Hadith
        if (!mounted) return;
        if (success) {
          showStyledSnackBar(context, message: 'تم إضافة البيانات بنجاح', isError: false);
          _resetState();
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
        'type': 'hadith',
      };
      
      try {
        await offlineService.saveHadithSubmissionToCache(submission);
        Workmanager().registerOneOffTask(
          "hadithSyncTask-${DateTime.now().millisecondsSinceEpoch}",
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



  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required List<GlobalKey<FormState>> formKeys,
    required Widget Function(T item, int index, GlobalKey<FormState> formKey)
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
              child: Column(
                children: [
                  _buildSection<endedSurahToSend>(
                    title: "تسميعات الأحاديث",
                    items: theAhadithToSendToProfile,
                    formKeys: _hadithFormKeys,
                    buildCard: (item, index, formKey) =>
                        AddHadith(hadithForForm: item, formKey: formKey),
                    onAdd: _addHadith,
                    onRemove: _removeHadith,
                    sectionIcon: Icons.menu_book_outlined,
                    sectionColor: Colors.brown.shade600,
                  ),
                  _buildSection<homeworkSurahToSend>(
                    title: "الوظائف",
                    items: theAhadithHomeworksToSendToProfile,
                    formKeys: _homeworkFormKeys,
                    buildCard: (item, index, formKey) => AddHadithHomework(
                        homeworkForForm: item, formKey: formKey),
                    onAdd: _addHomework,
                    onRemove: _removeHomework,
                    sectionIcon: Icons.edit_note_outlined,
                    sectionColor: Colors.blueGrey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoading ? const ModernLoader(size: 20 ,): SubmitFormButton(submit: submit),
        ),
      ],
    );
  }
}

