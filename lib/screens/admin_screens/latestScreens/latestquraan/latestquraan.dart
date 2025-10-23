// ✅ تم تعديل هذا الملف بالكامل ليعتمد على OfflineSyncService

import 'package:masjed/providers/connectivity_provider.dart';
import 'package:masjed/state/offline.dart'; // ✅ استيراد الملف الجديد
import 'package:workmanager/workmanager.dart'; // ✅ استيراد WorkManager

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/AddHomework.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestquraan/AddSora.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class Latestquraan extends StatefulWidget {
  final int userId;
  const Latestquraan({super.key, required this.userId});

  @override
  State<Latestquraan> createState() => _LatestquraanState();
}

class _LatestquraanState extends State<Latestquraan> {
  var theSoarToSendToProfile = <endedSurahToSend>[];
  var theHomewroksToSendToProfile = <homeworkSurahToSend>[];
  bool _isLoading = false;
  
  var _soraFormKeys = <GlobalKey<FormState>>[];
  var _homeworkFormKeys = <GlobalKey<FormState>>[];

  final OfflineSyncService offlineService = OfflineSyncService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndSync();
    });
  }

  Future<void> _initializeAndSync() async {
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    if (isOnline) {
      final user = context.read<User>();
      final success = await offlineService.sendPendingQuranSubmissions(user);
      if (success) {
        if (mounted) showStyledSnackBar(context, message: 'تمت مزامنة البيانات المحفوظة بنجاح');
      } else {
        if (mounted) showStyledSnackBar(context, message: 'فشل مزامنة بعض البيانات', isError: true);
      }
    }
  }

  void _addSora() {
    setState(() {
      theSoarToSendToProfile.add(
        // ✅ سيتم إنشاء الكائن مع القيمة الافتراضية 'ghaiban'
        endedSurahToSend(num: 0, from: 0, to: 0, mark: 0, point: 0),
      );
      _soraFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeSora() {
    setState(() {
      if (theSoarToSendToProfile.isNotEmpty) {
        theSoarToSendToProfile.removeLast();
        _soraFormKeys.removeLast();
      }
    });
  }

  void _addHomework() {
    setState(() {
      theHomewroksToSendToProfile.add(
        // ✅ سيتم إنشاء الكائن مع القيمة الافتراضية 'ghaiban'
        homeworkSurahToSend(num: 0, from: 0, to: 0),
      );
      _homeworkFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeHomework() {
    setState(() {
      if (theHomewroksToSendToProfile.isNotEmpty) {
        theHomewroksToSendToProfile.removeLast();
        _homeworkFormKeys.removeLast();
      }
    });
  }

  void _resetState() {
    setState(() {
      theSoarToSendToProfile = [];
      theHomewroksToSendToProfile = [];
      _soraFormKeys = [];
      _homeworkFormKeys = [];
    });
  }

  Future<void> submit() async {
    if (theSoarToSendToProfile.isEmpty && theHomewroksToSendToProfile.isEmpty) {
      showStyledSnackBar(context, message: 'لا توجد بيانات للإرسال', isError: true);
      return;
    }

    bool allValid = true;
    for (var key in _soraFormKeys) {
      if (!(key.currentState?.validate() ?? false)) allValid = false;
    }
    for (var key in _homeworkFormKeys) {
      if (!(key.currentState?.validate() ?? false)) allValid = false;
    }

    if (!allValid) {
      showStyledSnackBar(context, message: 'الرجاء ملء جميع الحقول المطلوبة', isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    for (var soraCard in theSoarToSendToProfile) {
      soraCard.dispatch(context);
    }
    for (var hwCard in theHomewroksToSendToProfile) {
      hwCard.dispatch(context);
    }
    
    User user = Provider.of<User>(context, listen: false);
    // ✅ دالة toJson الآن ستضيف حقل 'type' تلقائياً
    List<Map<String, dynamic>> soarJson = theSoarToSendToProfile.map((e) => e.toJson()).toList();
    List<Map<String, dynamic>> homeworkJson = theHomewroksToSendToProfile.map((e) => e.toJson()).toList();
    final payload = [soarJson, homeworkJson];

    final isOnline = context.read<ConnectivityProvider>().isOnline;

    if (isOnline) {
      try {
        bool success = await user.add_latest_quraan_hadith(widget.userId, payload, true);
        if (!context.mounted) return;
        if (success) {
          showStyledSnackBar(context, message: 'تم إضافة البيانات بنجاح', isError: false);
          _resetState();
        }
      } catch (e) {
        if (!context.mounted) return;
        showStyledSnackBar(context, message: e.toString(), isError: true);
      }
    } else {
      final submission = { 'userId': widget.userId, 'payload': payload, 'type': 'quran' };
      try {
        await offlineService.saveQuranSubmissionToCache(submission);
        Workmanager().registerOneOffTask(
          "quranSyncTask-${DateTime.now().millisecondsSinceEpoch}",
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
    
    if(mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ✅ تم تعديل هذه الدالة لتشمل زر التبديل
  Widget _buildSection<T>({
    required String title,
    required List<T> items,
    required List<GlobalKey<FormState>> formKeys,
    required Widget Function(T item, int index, GlobalKey<FormState> formKey) buildCard,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required IconData sectionIcon,
    required List<Color> gradientColors,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(sectionIcon, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Colors.white70, indent: 30, endIndent: 30),
            
            // ✅ تعديل هنا لعرض البطاقة مع زر التبديل
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              if (index < formKeys.length) {
                // استخراج النوع الحالي من الكائن
                String currentType = 'ghaiban'; // قيمة افتراضية
                if (item is endedSurahToSend) {
                  currentType = item.type;
                } else if (item is homeworkSurahToSend) {
                  currentType = item.type;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      buildCard(item, index, formKeys[index]),
                      const SizedBox(height: 10),
                      // ✅ زر التبديل الجديد
                      ToggleButtons(
                        isSelected: [currentType == 'ghaiban', currentType == 'nazaran'],
                        onPressed: (int newIndex) {
                          setState(() {
                            final newType = newIndex == 0 ? 'ghaiban' : 'nazaran';
                            if (item is endedSurahToSend) {
                              item.type = newType;
                            } else if (item is homeworkSurahToSend) {
                              item.type = newType;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        color: Colors.white.withOpacity(0.7),
                        fillColor: Colors.white.withOpacity(0.3),
                        splashColor: Colors.white.withOpacity(0.2),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('غيباً')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('نظراً')),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, size: 32), color: Colors.white),
                IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle, size: 32), color: Colors.white70),
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
                    title: "تسميعات القرآن",
                    items: theSoarToSendToProfile,
                    formKeys: _soraFormKeys,
                    buildCard: (item, index, formKey) => AddSora(sorahForForm: item, formKey: formKey),
                    onAdd: _addSora,
                    onRemove: _removeSora,
                    sectionIcon: Icons.menu_book_outlined,
                    gradientColors: [Colors.green.shade400, const Color.fromARGB(255, 88, 174, 165)],
                  ),
                  _buildSection<homeworkSurahToSend>(
                    title: "وظائف القرآن",
                    items: theHomewroksToSendToProfile,
                    formKeys: _homeworkFormKeys,
                    buildCard: (item, index, formKey) => AddHomework(homeworkForForm: item, formKey: formKey),
                    onAdd: _addHomework,
                    onRemove: _removeHomework,
                    sectionIcon: Icons.assignment_outlined,
                    gradientColors: [Colors.blue.shade400, const Color.fromARGB(255, 144, 152, 201)],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoading
              ? const ModernLoader(size: 20,)
              : SubmitFormButton(submit: submit),
        ),
      ],
    );
  }
}