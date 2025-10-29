import 'package:flutter/material.dart';

import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/stars_grade.dart';
import 'package:masjed/providers/connectivity_provider.dart';
// ... (باقي الاستيرادات)
import 'package:masjed/models/objects.dart';
import 'package:masjed/state/achievements_cache_service.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class UserLatest extends StatefulWidget {
  final int userId;
  final reciveLatest? initialData; // بيانات أولية يتم تمريرها

  const UserLatest({super.key, required this.userId, this.initialData});

  factory UserLatest.forteacher(
      {required int userId, reciveLatest? initialData}) {
    return UserLatest(userId: userId, initialData: initialData);
  }

  @override
  State<UserLatest> createState() => _UserLatestState();
}

class _UserLatestState extends State<UserLatest> {
  reciveLatest? _latestData;
  bool _isLoading = false;
  final AchievementsCacheService _cacheService = AchievementsCacheService();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    // إذا تم تمرير بيانات، اعرضها فورًا
    if (widget.initialData != null) {
      setState(() {
        _latestData = widget.initialData;
      });
      // ثم حاول تحديثها في الخلفية إذا كان هناك انترنت
      if (context.read<ConnectivityProvider>().isOnline) {
        _downloadData(showLoader: true);
      }
    } else {
      // إذا لم يتم تمرير بيانات، ابدأ عملية الجلب/التحميل من الكاش
      _downloadData(showLoader: true);
    }
  }

  void onDelete() async {
    // عند حذف عنصر من القرآن، نقوم بإعادة تحميل البيانات
    await _downloadData(showLoader: false);
  }

  Future<void> _downloadData({bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) setState(() => _isLoading = true);

    try {
      final isOnline = context.read<ConnectivityProvider>().isOnline;
      reciveLatest? data;
      final userProvider = Provider.of<User>(context, listen: false);

      if (isOnline) {
        final profile = Provider.of<Profile>(context, listen: false);
        data = await profile.get_Latest(userProvider.privilege!, widget.userId);
        if (data != null) {
          await _cacheService.saveAllAchievements({widget.userId: data});
        }
      } else {
        data = await _cacheService.getAchievementsForUser(widget.userId);
      }

      if (mounted) {
        setState(() => _latestData = data);
        if (data == null) {
          showStyledSnackBar(context,
              message: 'لا توجد بيانات لعرضها', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showStyledSnackBar(context, message: 'حدث خطأ: $e', isError: true);
      }
    } finally {
      if (mounted && showLoader) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    final userProviderPrivilege =
        Provider.of<User>(context, listen: false).privilege;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'لمتابعة الإنجازات السابقة توجه الى صفحة التقارير',
            style: TextStyle(
              fontSize: sizeConfig.defaultSize! * 2.2,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          // زر تحديث البيانات (يعمل فقط عند وجود انترنت)
          if (isOnline)
            // زر تحميل البيانات
            Card(
              elevation: 5,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      'تحديث البيانات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DownloaddataContextBTN(
                      submit: (ctx, prof) => _downloadData(showLoader: true),
                      logging: _isLoading,
                      profile: Provider.of<Profile>(context, listen: false),
                      sendedContext: context,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 30),

          // عرض البيانات
          if (_isLoading)
            const Center(child: ModernLoader())
          else if (_latestData != null)
            Column(
              children: [
                QuranWidget(
                    quran: _latestData!.quran ?? [],
                    quranHomework: _latestData!.quranHomework ?? [],
                    CreatedAt: _latestData!.createdAt ?? '',
                    userId: widget.userId,
                    onDeleted: onDelete,
                    isOnline: isOnline, // ✅ أضف هذا
                    userProviderPrivilege: userProviderPrivilege!),
                HadithWidget(
                  hadith: _latestData?.hadith ?? [],
                  hadithHomework: _latestData?.hadithHomework ?? [],
                  CreatedAt: _latestData?.createdAt ?? '',
                  userId: widget.userId, // ✅ إضافة
                  onDeleted: onDelete, // ✅ إضافة
                  isOnline: isOnline, // ✅ إضافة
                  userProviderPrivilege: userProviderPrivilege, // ✅ إضافة
                ),
                const SizedBox(height: 30),
                ActivityWidget(
                  activities: _latestData?.activities ?? [],
                  CreatedAt: _latestData?.createdAt ?? '',
                  userId: widget.userId, // ✅ إضافة
                  onDeleted: onDelete, // ✅ إضافة
                  isOnline: isOnline, // ✅ إضافة
                  userProviderPrivilege: userProviderPrivilege, // ✅ إضافة
                ),
                const SizedBox(height: 30),
                NotesWidget(
                  note: _latestData?.note ?? '',
                  LPoints: _latestData?.LPoints ?? '',
                  CreatedAt: _latestData?.createdAt ?? '',
                  userId: widget.userId, // ✅ إضافة
                  onDeleted: onDelete, // ✅ إضافة
                  isOnline: isOnline, // ✅ إضافة
                  userProviderPrivilege: userProviderPrivilege, // ✅ إضافة
                ),
                const SizedBox(height: 20),
              ],
            )
          else
            const Text('لا توجد بيانات لعرضها حاليًا.'),
        ],
      ),
    );
  }
}

//=============== واجهات عرض البيانات (تم إعادة بنائها) ==================
class QuranWidget extends StatefulWidget {
  final List<dynamic> quran;
  final List<dynamic> quranHomework;
  final String CreatedAt;
  final int userId;
  final VoidCallback onDeleted;
  final bool isOnline;
  final int userProviderPrivilege;

  const QuranWidget({
    super.key,
    required this.quran,
    required this.quranHomework,
    required this.CreatedAt,
    required this.userId,
    required this.onDeleted,
    required this.isOnline,
    required this.userProviderPrivilege,
  });

  @override
  State<QuranWidget> createState() => _QuranWidgetState();
}

class _QuranWidgetState extends State<QuranWidget> {
  bool _isDeleting = false; // 🔄 متغير حالة الحذف

  @override
  Widget build(BuildContext context) {
    final quranAchievements =
        widget.quran.whereType<Map<String, dynamic>>().toList();
    final homeworks =
        widget.quranHomework.whereType<Map<String, dynamic>>().toList();

    return _InfoCard(
      title: 'تسميع القرآن',
      imagePath: 'images/quran_book.png',
      createdAt: widget.CreatedAt,
      child: Column(
        children: [
          if (quranAchievements.isNotEmpty) ...[
            const _SectionTitle(title: 'آخر تسميع : '),
            ...List<Widget>.generate(quranAchievements.length, (i) {
              final item = quranAchievements[i];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _GradedListItem(
                      icon: Icons.bookmark_outline_sharp,
                      text:
                          'سورة ${Quraansoarmanage.soarList[item['num']]} من الاية ${item['from']} الى ${item['to']}',
                      mark: (item['mark'] as num).round(),
                      points: item['point'],
                      type: item['type'] ?? 'ghaiban',
                      showType: true,
                    ),
                  ),
                  if (widget.isOnline && widget.userProviderPrivilege != 1)
                    _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        :PopupMenuButton<String>(
  icon: Icon(
    Icons.more_vert_rounded,
    color: Colors.grey.shade800,
    size: 26,
  ),
  tooltip: 'خيارات',
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  color: Colors.white,
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  shadowColor: Colors.black.withOpacity(0.1),
  onSelected: (value) {
    if (value == 'delete') {
      _confirmDelete(context, item);
    }
  },
  itemBuilder: (BuildContext context) => [
    PopupMenuItem<String>(
      value: 'delete',
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'حذف',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
    const PopupMenuDivider(height: 6),
],
),
],
              );
            }),
          ],
          if (homeworks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle(title: 'آخر واجب : '),
            ...List<Widget>.generate(homeworks.length, (i) {
              final item = homeworks[i];
              return _SimpleListItem(
                icon: Icons.bookmark_outline_sharp,
                text:
                    'سورة ${Quraansoarmanage.soarList[item['num']]} من الاية ${item['from']} الى ${item['to']}',
                type: item['type'] ?? 'ghaiban',
                showType: true,
              );
            }),
          ],
          if (quranAchievements.isEmpty && homeworks.isEmpty)
            const Text("لا توجد بيانات قرآن لعرضها",
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ====== دوال الحذف كما هي لكن مع تحديث حالة اللودر ======

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا التسميع؟ سيتم خصم النقاط والعلامة.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete(context, item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
      BuildContext context, Map<String, dynamic> item) async {
    setState(() => _isDeleting = true);
    try {
      final userProvider = Provider.of<User>(context, listen: false);
      bool success =
          await userProvider.deleteLatestQuranItem(widget.userId, item);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التسميع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDeleted();
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

// ✅ تحويله إلى StatefulWidget
class HadithWidget extends StatefulWidget {
  final List<dynamic> hadith;
  final List<dynamic> hadithHomework;
  final String CreatedAt;
  // ✅ إضافة الخصائص الجديدة
  final int userId;
  final VoidCallback onDeleted;
  final bool isOnline;
  final int userProviderPrivilege;

  const HadithWidget({
    super.key,
    required this.hadith,
    required this.hadithHomework,
    required this.CreatedAt,
    required this.userId,
    required this.onDeleted,
    required this.isOnline,
    required this.userProviderPrivilege,
  });

  // ✅ دالة المساعدة لتحويل الرقم إلى اسم
  String getHadithTitleByNumber(int hadithNum) {
    final index = hadithNum;
    if (index != -1 && index < Quraansoarmanage.AhadithTitles.length) {
      return Quraansoarmanage.AhadithTitles[index];
    }
    return 'حديث رقم $hadithNum'; // نص احتياطي
  }

  @override
  State<HadithWidget> createState() => _HadithWidgetState();
}

class _HadithWidgetState extends State<HadithWidget> {
  // ✅ إضافة متغير حالة الحذف
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    // ✅ تنقية البيانات أولاً
    final hadithAchievements =
        widget.hadith.whereType<Map<String, dynamic>>().toList();
    final homeworks =
        widget.hadithHomework.whereType<Map<String, dynamic>>().toList();

    return _InfoCard(
      title: 'تسميع الحديث',
      imagePath: 'images/hadith_book.png',
      createdAt: widget.CreatedAt,
      child: Column(
        children: [
          if (hadithAchievements.isNotEmpty) ...[
            const _SectionTitle(title: 'آخر تسميع : '),
            ...List<Widget>.generate(hadithAchievements.length, (i) {
              final item = hadithAchievements[i];
              final String hadithName =
                  widget.getHadithTitleByNumber(item['num']);
              // ✅ تحويلها إلى Row لإضافة الزر
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _GradedListItem(
                      icon: Icons.book_outlined,
                      text: hadithName,
                      mark: item['mark'],
                      points: item['point'],
                      type: 'ghaiban',
                      showType: false,
                    ),
                  ),
                  // ✅ إضافة زر الحذف بنفس منطق القرآن
                  if (widget.isOnline && widget.userProviderPrivilege != 1)
                    _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        :PopupMenuButton<String>(
  icon: Icon(
    Icons.more_vert_rounded,
    color: Colors.grey.shade800,
    size: 26,
  ),
  tooltip: 'خيارات',
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  color: Colors.white,
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  shadowColor: Colors.black.withOpacity(0.1),
  onSelected: (value) {
    if (value == 'delete') {
      _confirmDelete(context, item);
    }
  },
  itemBuilder: (BuildContext context) => [
    PopupMenuItem<String>(
      value: 'delete',
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'حذف',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
    const PopupMenuDivider(height: 6),
],
),
],
              );
            }),
          ],
          if (homeworks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle(title: 'آخر واجب : '),
            ...List<Widget>.generate(homeworks.length, (i) {
              final item = homeworks[i];
              final String hadithName =
                  widget.getHadithTitleByNumber(item['num']);
              return _SimpleListItem(
                icon: Icons.book_outlined,
                text: hadithName,
                type: 'ghaiban',
                showType: false,
              );
            }),
          ],
          if (hadithAchievements.isEmpty && homeworks.isEmpty)
            const Text("لا توجد بيانات أحاديث لعرضها",
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ====== ✅ إضافة دوال الحذف (منسوخة من القرآن) ======

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا التسميع؟ سيتم خصم النقاط والعلامة.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete(context, item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
      BuildContext context, Map<String, dynamic> item) async {
    setState(() => _isDeleting = true);
    try {
      final userProvider = Provider.of<User>(context, listen: false);
      // ✅ !!! استدعاء دالة الحذف الجديدة الخاصة بالحديث
      bool success =
          await userProvider.deleteLatestHadithItem(widget.userId, item);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التسميع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDeleted(); // ✅ استدعاء الكول باك لتحديث الصفحة
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

// ✅ تحويله إلى StatefulWidget
class ActivityWidget extends StatefulWidget {
  final List<dynamic> activities;
  final String CreatedAt;
  // ✅ إضافة الخصائص الجديدة
  final int userId;
  final VoidCallback onDeleted;
  final bool isOnline;
  final int userProviderPrivilege;

  const ActivityWidget({
    super.key,
    required this.activities,
    required this.CreatedAt,
    required this.userId,
    required this.onDeleted,
    required this.isOnline,
    required this.userProviderPrivilege,
  });

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  // ✅ إضافة متغير حالة الحذف
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    // ✅ تنقية البيانات أولاً
    final activityItems =
        widget.activities.whereType<Map<String, dynamic>>().toList();

    return _InfoCard(
      title: 'أنشطة',
      imagePath: 'images/checklist.png',
      createdAt: widget.CreatedAt,
      child: Column(
        children: [
          if (activityItems.isNotEmpty)
            ...List<Widget>.generate(activityItems.length, (i) {
              final item = activityItems[i];
              // ✅ تحويلها إلى Row لإضافة الزر
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _GradedListItem(
                      icon: Icons.sticky_note_2_outlined,
                      text: 'اسم النشاط: ${item['name']}',
                      mark: item['mark'],
                      points: item['point'],
                      type: 'ghaiban',
                      showType: false,
                    ),
                  ),
                  // ✅ إضافة زر الحذف بنفس منطق القرآن
                  if (widget.isOnline && widget.userProviderPrivilege != 1)
                    _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        :PopupMenuButton<String>(
  icon: Icon(
    Icons.more_vert_rounded,
    color: Colors.grey.shade800,
    size: 26,
  ),
  tooltip: 'خيارات',
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  color: Colors.white,
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  shadowColor: Colors.black.withOpacity(0.1),
  onSelected: (value) {
    if (value == 'delete') {
      _confirmDelete(context, item);
    }
  },
  itemBuilder: (BuildContext context) => [
    PopupMenuItem<String>(
      value: 'delete',
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'حذف',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
    const PopupMenuDivider(height: 6),
],
),
],
              );
            })
          else
            const Text("لا توجد أنشطة لعرضها",
                style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ====== ✅ إضافة دوال الحذف (منسوخة من القرآن) ======

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد من رغبتك في حذف هذا النشاط؟ سيتم خصم النقاط والعلامة.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete(context, item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
      BuildContext context, Map<String, dynamic> item) async {
    setState(() => _isDeleting = true);
    try {
      final userProvider = Provider.of<User>(context, listen: false);
      // ✅ !!! استدعاء دالة الحذف الجديدة الخاصة بالنشاط
      bool success =
          await userProvider.deleteLatestActivityItem(widget.userId, item);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف النشاط بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDeleted(); // ✅ استدعاء الكول باك لتحديث الصفحة
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

// ✅ تحويله إلى StatefulWidget
class NotesWidget extends StatefulWidget {
  final String note;
  final String LPoints;
  final String CreatedAt;

  // ✅ إضافة الخصائص الجديدة
  final int userId;
  final VoidCallback onDeleted;
  final bool isOnline;
  final int userProviderPrivilege;

  const NotesWidget({
    super.key,
    required this.note,
    required this.LPoints,
    required this.CreatedAt,
    required this.userId,
    required this.onDeleted,
    required this.isOnline,
    required this.userProviderPrivilege,
  });

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  // ✅ إضافة متغير حالة الحذف
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    // ✅ التحقق إذا كانت البيانات موجودة فعلاً
    final bool hasData =
        widget.note.isNotEmpty || (double.tryParse(widget.LPoints) ?? 0) > 0;
    const Color noteHeaderColor = Color(0xFFCC6F65);
    const Color noteTextColor = Colors.white;
    final Color cardColor = Colors.red.shade200;
    return _InfoCard(
      headerColor: noteHeaderColor,
      headerTextColor: noteTextColor,
      cardColor: cardColor,
      imageSize: sizeConfig.defaultSize! * 5,
      title: 'ملاحظات ونقاط إضافية',
      imagePath: 'images/penalty.png', // تأكد من وجود صورة مناسبة
      createdAt: widget.CreatedAt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasData) ...[
            _SimpleListItem(
              text: widget.note.isNotEmpty ? widget.note : 'لا توجد إنذارات',
              icon: Icons.sticky_note_2_outlined,
              backgroundColor: Colors.red.shade300,
              textColor: noteTextColor,
              type: 'ghaiban',
              showType: false, // تعديل: إخفاء النوع هنا
            ),
            const SizedBox(height: 15),

            if ((double.tryParse(widget.LPoints) ?? 0) > 0)
              _SimpleListItem(
                icon: Icons.do_not_disturb_alt_outlined,
                text: 'النقاط المخصومة: ${widget.LPoints}',
                backgroundColor: Colors.red.shade300,
                textColor: noteTextColor,
                type: 'ghaiban',
                showType: false, // تعديل: إخفاء النوع هنا
              ),
            // ✅ إضافة زر الحذف
            if (widget.isOnline && widget.userProviderPrivilege != 1)
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
                child: Center(
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ElevatedButton(
                          onPressed: () => _confirmDelete(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'حذف الملاحظات والنقاط',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
          ] else
            const Text("لا توجد ملاحظات أو نقاط إضافية",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        ],
      ),
    );
  }

  // ====== ✅ إضافة دوال الحذف (هنا لا نحتاج 'item') ======

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
            'هل أنت متأكد من حذف الملاحظة والنقاط الإضافية؟ سيتم خصم النقاط.'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    setState(() => _isDeleting = true);
    try {
      final userProvider = Provider.of<User>(context, listen: false);
      // ✅ !!! استدعاء دالة الحذف الجديدة الخاصة بالملاحظات
      bool success = await userProvider.deleteLatestNoteItem(widget.userId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الملاحظات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onDeleted(); // ✅ استدعاء الكول باك لتحديث الصفحة
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}
//=============== ويدجتات مساعدة وقابلة لإعادة الاستخدام (تم التعديل) ==================

class _InfoCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String createdAt;
  final Widget child;
  final Color? headerColor;
  final Color? cardColor;
  final Color? headerTextColor;
  final double? imageSize;

  const _InfoCard({
    required this.title,
    required this.imagePath,
    required this.createdAt,
    required this.child,
    this.headerColor,
    this.cardColor,
    this.headerTextColor,
    this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeaderColor = headerColor ?? Colors.greenAccent.shade400;
    final effectiveCardColor = cardColor ?? Colors.white;
    final effectiveHeaderTextColor = headerTextColor ?? Colors.black87;
    final effectiveImageSize = imageSize ?? 80.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Column(
        children: [
          // عنوان البطاقة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effectiveHeaderColor,
                  effectiveHeaderColor.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: effectiveHeaderTextColor),
              ),
            ),
          ),
          // البطاقة نفسها
          Card(
            color: effectiveCardColor,
            elevation: 6,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
              child: Column(
                children: [
                  // الصورة
                  Container(
                    width: effectiveImageSize,
                    height: effectiveImageSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 3),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // المحتوى
                  child,
                  const SizedBox(height: 12),
                  // ===== التعديل الثاني هنا: استبدال ListTile بـ Row مرن =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined,
                            color: Colors.black54),
                        const SizedBox(width: 8),
                        const Text(
                          'تاريخ الإضافة:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const Spacer(), // يدفع النص التالي إلى اليمين
                        Flexible(
                          // يسمح للنص بالالتفاف إذا كانت المساحة ضيقة
                          child: Text(
                            createdAt.isNotEmpty
                                ? '${createdAt.split('T')[0]} عند الساعة: ${createdAt.split('T')[1].split(":")[0]}'
                                : 'البيانات غير محدثة',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ===== نهاية التعديل الثاني =====
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان فرعي داخل البطاقة
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800),
      ),
    );
  }
}

/// عنصر بقائمة مع تقييم بالنجوم
class _GradedListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final int mark; // من 0 إلى 100
  final dynamic points;
  final String type; // 'ghaiban' or 'nazaran'
  final bool showType; // تعديل: متغير جديد للتحكم في إظهار النوع

  const _GradedListItem({
    required this.icon,
    required this.text,
    required this.mark,
    required this.points,
    required this.type,
    this.showType = false, // تعديل: القيمة الافتراضية هي false
  });

  @override
  Widget build(BuildContext context) {
    final bool isGhaiban = type == 'ghaiban';

    // ألوان مختلفة حسب النوع
    final Color primaryColor =
        isGhaiban ? Colors.green.shade800 : Colors.blue.shade800;
    final Color secondaryColor =
        isGhaiban ? Colors.green.shade700 : Colors.blue.shade700;
    final List<Color> gradientColors = isGhaiban
        ? [Colors.green.shade100, Colors.green.shade50]
        : [Colors.blue.shade100, Colors.blue.shade50];
    final String typeText = isGhaiban ? 'غيبا' : 'نظرا';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    // تعديل: إظهار الشريحة بشكل شرطي
                    if (showType)
                      Chip(
                        label: Text(typeText,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
              // ===== التعديل الأول هنا: إضافة FittedBox =====
              Expanded(
                flex: 4,
                child: FittedBox(
                  fit: BoxFit.scaleDown, // لمنع التكبير غير الضروري
                  child: Grade(
                    mark,
                  ),
                ),
              ),
              // ===== نهاية التعديل الأول =====
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "النقاط المكتسبة: $points",
              style: TextStyle(fontSize: 14, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// ويدجت لعرض عنصر بسيط في قائمة
class _SimpleListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final String type; // 'ghaiban' or 'nazaran'
  final bool showType; // تعديل: متغير جديد للتحكم في إظهار النوع

  const _SimpleListItem({
    required this.icon,
    required this.text,
    required this.type,
    this.showType = false, // تعديل: القيمة الافتراضية هي false
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGhaiban = type == 'ghaiban';

    // ألوان مختلفة حسب النوع
    final Color defaultBgColor =
        isGhaiban ? Colors.green.shade100 : Colors.blue.shade100;
    final Color defaultTxtColor =
        isGhaiban ? Colors.green.shade900 : Colors.blue.shade900;
    final Color defaultIconColor =
        isGhaiban ? Colors.green.shade700 : Colors.blue.shade700;
    final String typeText = isGhaiban ? 'غيبا' : 'نظرا';

    final bgColor = backgroundColor ?? defaultBgColor;
    final txtColor = textColor ?? defaultTxtColor;
    final iconColor = textColor ?? defaultIconColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        elevation: 3,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: txtColor,
                  ),
                ),
              ),
              // تعديل: إظهار الشريحة بشكل شرطي
              if (showType) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(typeText,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
