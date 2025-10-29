// // ✅ تم تعديل هذا الملف بالكامل
// import 'dart:convert';
// import 'dart:io';
// // ✅ --- بداية الإضافة ---
// import 'package:flutter/services.dart'; // Required for Clipboard
// import 'package:masjed/core/utils/QuraansoarManage.dart';
// // ✅ --- نهاية الإضافة ---
// import 'package:masjed/core/utils/sizeConfig.dart';
// import 'package:masjed/providers/connectivity_provider.dart';
// import 'package:masjed/state/achievements_cache_service.dart';
// import 'package:masjed/state/daoraState.dart';
// import 'package:masjed/state/offline.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:masjed/core/utils/snackBarHelper.dart';
// import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
// import 'package:masjed/core/widgets/RealisticAtomLoader.dart';
// import 'package:masjed/models/objects.dart';
// import 'package:masjed/screens/user_Ranking_screen/popupmenu_for_rank_page.dart';
// import 'package:masjed/state/profile.dart';
// import 'package:masjed/state/user.dart';
// import 'package:provider/provider.dart';
// import 'package:masjed/core/widgets/pulse_loader.dart';

// class ListContentForRankingPage extends StatefulWidget {
//   final bool global;

//   const ListContentForRankingPage(this.global, {super.key});

//   @override
//   State<ListContentForRankingPage> createState() =>
//       _ListContentForRankingPageState();
// }

// // ✅ الخطوة 1: أضف AutomaticKeepAliveClientMixin
// class _ListContentForRankingPageState extends State<ListContentForRankingPage>
//     with AutomaticKeepAliveClientMixin<ListContentForRankingPage> {
//   // ✅ الخطوة 2: اجعل wantKeepAlive ترجع true للحفاظ على الحالة
//   @override
//   bool get wantKeepAlive => true;

//   final ScrollController controller = ScrollController();
//   final TextEditingController reankMenucController = TextEditingController();
//   OneUserRank? specificUser;
//   int indexOf = -1;
//   List<OneUserRank> reankMenu = [];
//   List<int> watingStudents = [];
//   List<WantingCheckBox> WantingStudentsCheckBox = [];
//   bool isLoading = true;

//   late Profile _profileProvider;

//   @override
//   void initState() {
//     super.initState();
//     _profileProvider = Provider.of<Profile>(context, listen: false);

//     // لإصلاح خطأ استدعاء SnackBar قبل اكتمال البناء
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // انتظر لحظة قصيرة للسماح ببناء الواجهة ثم غيّر الحالة
//       // Future.delayed(const Duration(milliseconds: 1000), () {
//       //   context.read<ConnectivityProvider>().forceOffline(true); // true = force offline
//       // });
//       _initializePage();
//     });
//   }

//   @override
//   void dispose() {
//     reankMenucController.dispose();
//     super.dispose();
//   }

// // في ملف ListContentForRankingPage.dart

//   Future<void> _initializePage() async {
//     if (!mounted) return;

//     final isOnline = context.read<ConnectivityProvider>().isOnline;

//     if (isOnline) {
//       // ✅ --- بداية التعديل ---
//       // إظهار رسالة للمستخدم بأن المزامنة جارية
//       showStyledSnackBar(context,
//           message: 'جاري مزامنة البيانات المحفوظة...', isError: false);

//       // استدعاء خدمة المزامنة الشاملة
//       final offlineService = OfflineSyncService();
//       final user = context.read<User>(); // جلب بيانات المستخدم لإرسالها

//       // مزامنة جميع الإنجازات (قرآن، حديث، ..إلخ)
//       await offlineService.syncAllPendingData(user);

//       // مزامنة الغيابات المعلقة
//       await _sendPendingAbsences();

//       // إظهار رسالة اكتمال
//       if (mounted) {
//         showStyledSnackBar(context, message: 'اكتملت المزامنة بنجاح');
//       }

//       // ✅ --- نهاية التعديل ---

//       // تحديث بيانات الشاشة بعد اكتمال المزامنة
//       await UpdateScreen(context, _profileProvider);
//     } else {
//       showStyledSnackBar(context,
//           message: 'أنت في وضع عدم الاتصال', isError: false);
//       await _loadRanksFromCache();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     sizeConfig().init(context); // التأكد من تهيئة القياسات
//     User user = Provider.of<User>(context, listen: false);
//     final isOnline = context.watch<ConnectivityProvider>().isOnline;

//     return Consumer<Profile>(
//       builder: (context, profile, child) {
//         return Expanded(
//           child: Stack(
//             children: [
//               // 🌀 عرض القائمة الرئيسية أو حالات التحميل/الفراغ
//               if (isLoading)
//                 const Center(child: RealisticAtomLoader(size: 70))
//               else if (reankMenu.isEmpty)
//                 const Center(
//                   child: Text(
//                     'لا يوجد طلاب لعرضهم',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 )
//               else
//                 Column(
//                   children: [
//                     if (widget.global) _buildStudentDropdownMenu(),
//                     Expanded(
//                       child: ListView.builder(
//                         // زيادة الحشوة السفلية لإفساح المجال للأزرار الجديدة
//                         padding: const EdgeInsets.only(bottom: 120),
//                         itemCount: specificUser == null ? reankMenu.length : 1,
//                         itemBuilder: (context, i) {
//                           final index = specificUser == null ? i : indexOf;
//                           if (index == -1) return const SizedBox.shrink();
//                           return _buildRankListItem(
//                               context, index, user, isOnline);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),

//               // ✅ --- بداية التعديل: استخدام دالة واحدة لبناء كل الأزرار السفلية ---
//               // هذا يضمن أن الأزرار ستكون دائماً في صف واحد ولن تتداخل أبداً
//               _buildBottomActionButtons(profile, isOnline),
//               // ✅ --- نهاية التعديل ---
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// ✅ دالة جديدة ومحسنة لبناء شريط الأزرار السفلي بطريقة متجاوبة
//   Widget _buildBottomActionButtons(Profile profile, bool isOnline) {
//      final userProvider = Provider.of<User>(context, listen: false);
//     // تحديد حجم الخط بناءً على حجم الشاشة ليكون متجاوباً
//     final double labelFontSize = sizeConfig.defaultSize! * 1.4;
//     final double titleFontSize = sizeConfig.defaultSize! * 1.8;

//     // استخدام Positioned مرة واحدة فقط لوضع شريط الأزرار في الأسفل
//     return Positioned(
//       bottom: 10,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         // استخدام Row لترتيب الأزرار أفقياً ومنع التداخل
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             // 🔄 زر تحديث البيانات (الزر الأيسر)
//             if (!isLoading && isOnline)
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'تحديث',
//                     style: TextStyle(
//                       fontSize: titleFontSize, // حجم خط متجاوب
//                       color: Colors.black,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   DownloaddataContextBTN(
//                     submit: UpdateScreen,
//                     logging: isLoading,
//                     profile: profile,
//                     sendedContext: context,
//                   ),
//                 ],
//               ),

//             // لجعل الزر الأيسر يظهر حتى لو كان الزر الأوسط مخفياً
//             if (isLoading || !isOnline) const Spacer(),

//             // 📋 زر نسخ التقرير (الزر الأوسط)
//             if (!isLoading && reankMenu.isNotEmpty &&userProvider.privilege !=1)
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'نسخ التقرير',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: labelFontSize), // حجم خط متجاوب
//                   ),
//                   const SizedBox(height: 4),
//                   FloatingActionButton(
//                     backgroundColor: Colors.blueAccent,
//                     tooltip: 'نسخ تقرير الإنجازات للواتساب',
//                     onPressed: _generateAndCopyReport,
//                     child: const Icon(Icons.copy, color: Colors.white),
//                   ),
//                 ],
//               ),

//             // 🚫 ✅ أزرار الغياب (الزر الأيمن)
//             // يتم عرض زر واحد فقط حسب الحالة (إما "الكل حاضر" أو "إرسال غياب")
//             if (!isLoading && reankMenu.isNotEmpty &&( userProvider.privilege ==3|| !widget.global ))
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   // سيتم عرض هذا النص إذا لم يكن هناك غياب
//                   if (watingStudents.isEmpty && userProvider.privilege !=1 )
//                     Text(
//                       'الكل حاضر',
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: labelFontSize), // حجم خط متجاوب
//                     )
//                   // أو سيتم عرض هذا النص إذا كان هناك طلاب غائبون
//                   else if (userProvider.privilege !=1 )
//                     Text(
//                       'إرسال غياب (${watingStudents.length})',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: labelFontSize), // حجم خط متجاوب
//                     ),
//                   const SizedBox(height: 4),
//                   // سيتم عرض هذا الزر إذا لم يكن هناك غياب
//                   if (watingStudents.isEmpty  && userProvider.privilege !=1 )
//                     FloatingActionButton(
//                       backgroundColor: Colors.green,
//                       tooltip: 'تأكيد حضور جميع الطلاب',
//                       onPressed: () async => _submitAbsences(profile),
//                       child: const Icon(Icons.done_all, color: Colors.white),
//                     )
//                   // أو سيتم عرض هذا الزر إذا كان هناك طلاب غائبون
//                    else if (userProvider.privilege !=1)
//                     FloatingActionButton(
//                       backgroundColor: Colors.red,
//                       tooltip: 'إرسال غياب الطلاب المحددين',
//                       onPressed: () async => _submitAbsences(profile),
//                       child:
//                           const Icon(Icons.upload_rounded, color: Colors.white),
//                     ),
//                 ],
//               ),

//             // لجعل الزر الأيمن يظهر حتى لو كان الزر الأوسط مخفياً
//             if (isLoading || reankMenu.isEmpty) const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }


// Future<void> _generateAndCopyReport() async {
//   // إظهار مؤشر تحميل
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const Center(child: PulseLoader(size: 70)),
//   );

//   final cacheService = AchievementsCacheService();
//   final stringBuffer = StringBuffer();

//   stringBuffer.writeln('📋 *تقرير الإنجازات اليومي* 📋');
//   stringBuffer.writeln('-----------------------------------');

//   final students = List<OneUserRank>.from(reankMenu);

//   for (final student in students) {
//     final achievements =
//         await cacheService.getAchievementsForUser(student.user_id);

//     // ✅ تحديد حالة آخر حضور
//     final bool isPresent = student.lastAttendanceStatus == 'present';
//     final String attendanceEmoji = isPresent ? '✅' : '❌';
//     final String attendanceText =
//         isPresent ? 'حاضر آخر لقاء' : 'غائب آخر لقاء';

//     stringBuffer.writeln(
//         '👤 *${student.user_name}* $attendanceEmoji ($attendanceText)');
//     stringBuffer.writeln('📅 إجمالي الغياب: ${student.missingDays}');

//     if (achievements == null) {
//       stringBuffer.writeln('📖 إنجاز القرآن الأخير : _________');
//       stringBuffer.writeln('📚 واجب القرآن الأخير : _________');
//       stringBuffer.writeln('📜 إنجاز الحديث الأخير : _________');
//       stringBuffer.writeln('✍️ واجب الحديث الأخير : _________');
//       stringBuffer.writeln('✨ آخر نشاط : _________');
//       stringBuffer.writeln('-----------------------------------');
//     } else {
//       // 🔹 إنجاز القرآن (لا تغيير هنا - كان صحيحاً)
//       final quranAchievements =
//           achievements.quran?.whereType<Map<String, dynamic>>().toList() ??
//               [];
//       final quranText = quranAchievements.isNotEmpty
//           ? quranAchievements
//               .map((item) =>
//                   'سورة ${Quraansoarmanage.soarList[item['num']]} (من ${item['from']} إلى ${item['to']})')
//               .join(' | ')
//           : '_________';
//       stringBuffer.writeln('📖 إنجاز القرآن الأخير : $quranText');

//       // 🔹 واجب القرآن (لا تغيير هنا - كان صحيحاً)
//       final quranHomework = achievements.quranHomework
//               ?.whereType<Map<String, dynamic>>()
//               .toList() ??
//           [];
//       final quranHomeworkText = quranHomework.isNotEmpty
//           ? quranHomework
//               .map((item) =>
//                   'سورة ${Quraansoarmanage.soarList[item['num']]} (من ${item['from']} إلى ${item['to']})')
//               .join(' | ')
//           : '_________';
//       stringBuffer.writeln('📚 واجب القرآن الأخير : $quranHomeworkText');

//       // 🔹 إنجاز الحديث (✅ تم التعديل)
//       final hadithAchievements =
//           achievements.hadith?.whereType<Map<String, dynamic>>().toList() ??
//               [];
//       final hadithText = hadithAchievements.isNotEmpty
//           ? hadithAchievements
//               .map((item) {
//                 // جلب اسم الحديث باستخدام الفهرس (num)
//                 final int index = item['num'];
//                 if (index >= 0 && index < Quraansoarmanage.AhadithTitles.length) {
//                   return Quraansoarmanage.AhadithTitles[index];
//                 } else {
//                   return 'حديث غير معروف (رقم $index)'; // للبيانات القديمة
//                 }
//               })
//               .join(' | ')
//           : '_________';
//       stringBuffer.writeln('📜 إنجاز الحديث الأخير : $hadithText');

//       // 🔹 واجب الحديث (✅ تم التعديل)
//       final hadithHomework = achievements.hadithHomework
//               ?.whereType<Map<String, dynamic>>()
//               .toList() ??
//           [];
//       final hadithHomeworkText = hadithHomework.isNotEmpty
//           ? hadithHomework
//               .map((item) {
//                 // جلب اسم الحديث باستخدام الفهرس (num)
//                 final int index = item['num'];
//                  if (index >= 0 && index < Quraansoarmanage.AhadithTitles.length) {
//                   return Quraansoarmanage.AhadithTitles[index];
//                 } else {
//                   return 'حديث غير معروف (رقم $index)'; // للبيانات القديمة
//                 }
//               })
//               .join(' | ')
//           : '_________';
//       stringBuffer.writeln('✍️ واجب الحديث الأخير : $hadithHomeworkText');

//       // 🔹 النشاط
//       final activities = achievements.activities
//               ?.whereType<Map<String, dynamic>>()
//               .toList() ??
//           [];
//       final activityText = activities.isNotEmpty
//           ? activities.map((item) => item['name']).join(' | ')
//           : '_________';
//       stringBuffer.writeln('✨ آخر نشاط : $activityText');
//       stringBuffer.writeln('-----------------------------------');
//       stringBuffer.writeln('');
//     }

//     stringBuffer.writeln(); // سطر فارغ للفصل بين الطلاب
//   }

//   // إغلاق مؤشر التحميل
//   if (mounted) Navigator.pop(context);

//   // نسخ النص إلى الحافظة
//   await Clipboard.setData(ClipboardData(text: stringBuffer.toString()));

//   // رسالة نجاح
//   if (mounted) {
//     showStyledSnackBar(context, message: 'تم نسخ تقرير الإنجازات بنجاح!');
//   }
// }
// // ✅ دالة جديدة لجلب وتخزين إنجازات كل الطلاب في الخلفية
//   Future<void> _cacheAllStudentAchievements(
//       List<OneUserRank> students, Profile profileProvider) async {
//     // print("Starting background cache for all student achievements...");
//     final cacheService = AchievementsCacheService();
//     final Map<int, reciveLatest> allAchievements = {};

//     final userProvider = Provider.of<User>(context, listen: false);

//     await Future.wait(students.map((student) async {
//       try {
//         // ✅ الآن هذا السطر صحيح لأن get_Latest تُرجع reciveLatest?
//         final reciveLatest? userProfile = await profileProvider.get_Latest(
//             userProvider.privilege!, student.user_id);
//         if (userProfile != null) {
//           allAchievements[student.user_id] = userProfile;
//         }
//       } catch (e) {
//         // print("Could not fetch achievements for user ${student.user_id}: $e");
//       }
//     }));

//     if (allAchievements.isNotEmpty) {
//       await cacheService.saveAllAchievements(allAchievements);
//     }
//     // print("Background caching finished.");
//   }

//   Future<void> UpdateScreen(BuildContext context, Profile profile) async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       int? daoraId =
//           Provider.of<Daorastate>(context, listen: false).currentDaoraId;
//       if (daoraId == null) {
//         if (mounted) {
//           showStyledSnackBar(context,
//               message: 'لم يتم تحديد الدورة الحالية', isError: true);
//         }
//         setState(() => isLoading = false);
//         return;
//       }

//       var result = await profile.get_rank(widget.global, daoraId);
//       if (!mounted) return;

//       if (result['success']) {
//         final newRankMenu = profile.RankUsers ?? [];
//         setState(() {
//           reankMenu = newRankMenu;
//           WantingStudentsCheckBox = newRankMenu.map((userRank) {
//             return WantingCheckBox(checked: false, id: userRank.user_id);
//           }).toList();
//           watingStudents = [];
//         });
//         await _saveRanksToCache(reankMenu);

//         // ================== بداية التعديل ==================
//         // هنا يتم التحقق من شروط حفظ الإنجازات
//         final user = Provider.of<User>(context, listen: false);
//         final bool shouldCacheAchievements = (user.privilege == 2 &&
//                 !widget.global) || // مشرف حلقة وفي شاشة الحلقة
//             (user.privilege == 3); // مشرف عام

//         if (shouldCacheAchievements) {
//           // print("✅ الشروط تحققت: سيتم حفظ إنجازات الطلاب في الخلفية.");
//           // لا نستخدم await هنا لكي لا نُعطّل واجهة المستخدم
//           _cacheAllStudentAchievements(newRankMenu, profile);
//         } else {
//           // print("❌ الشروط لم تتحقق: لن يتم حفظ إنجازات الطلاب.");
//         }
//         // ================== نهاية التعديل ==================
//       } else {
//         showStyledSnackBar(context, message: result['message'], isError: true);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       showStyledSnackBar(context,
//           message: 'حدث خطأ في تحديث الواجهة', isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
// Future<void> _submitAbsences(Profile profile) async {
//     // --- بداية: إضافة كود التأكيد ---
//     if (widget.global) {
//       // 1. اعرض نافذة التأكيد وانتظر النتيجة
//       final bool? didConfirm = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false, // منع الإغلاق بالضغط خارج النافذة
//         builder: (BuildContext dialogContext) {
//           return AlertDialog(
//             title: const Text('⚠️ تنبيه هام'),
//             content: const Text(
//               'هل أنت متأكد من إرسال التفقد لـ (جميع طلاب المسجد)؟\n\n'
//               'سيتم تحديث حالة الحضور لآخر يوم لـ (كل الطلاب). الطلاب  المسجلين في قائمة الغياب الحالية سيتم اعتبارهم (حاضرين).',
//             ),
//             actions: <Widget>[
//               // زر الإلغاء
//               TextButton(
//                 child: const Text('إلغاء'),
//                 onPressed: () {
//                   // إغلاق النافذة وإرجاع (false)
//                   Navigator.pop(dialogContext, false); 
//                 },
//               ),
//               // زر التأكيد (استخدمنا FilledButton للتمييز)
//               FilledButton(
//                 child: const Text('نعم، إرسال للجميع'),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.red, // للتأكيد على خطورة الإجراء
//                 ),
//                 onPressed: () {
//                   // إغلاق النافذة وإرجاع (true)
//                   Navigator.pop(dialogContext, true); 
//                 },
//               ),
//             ],
//           );
//         },
//       );

//       // 2. التحقق من نتيجة النافذة
//       // إذا كانت النتيجة null (لم يختر) أو false (ضغط إلغاء)
//       if (didConfirm == null || didConfirm == false) {
//         return; // <-- أهم خطوة: أوقف الدالة ولا تكمل
//       }
//     }
//     // --- نهاية: إضافة كود التأكيد ---


//     // الكود المتبقي الخاص بك سيعمل فقط إذا تم التأكيد (أو إذا لم تكن global)
//     final isOnline = context.read<ConnectivityProvider>().isOnline;

//     if (isOnline) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => const Center(child: PulseLoader(size: 70)),
//       );

//       try {
//         final bool success = await profile.add_wanting_students(watingStudents, widget.global);
//         if (!mounted) return;
//         Navigator.pop(context); // إغلاق اللودر
//         if (success) {
//           showStyledSnackBar(context, message: 'تم إرسال التفقد بنجاح');
//           _resetAbsenceState();
//         }
//       } catch (e) {
//         if (!mounted) return;
//         Navigator.pop(context);
//         showStyledSnackBar(context, message: e.toString(), isError: true);
//       }
//     } else {
//       await _saveAbsencesToCache(watingStudents, widget.global);
//       showStyledSnackBar(context,
//           message: 'تم حفظ الغياب، سيتم إرساله عند توفر الإنترنت');
//       _resetAbsenceState();
//     }
//   }  void _resetAbsenceState() {
//     setState(() {
//       watingStudents = [];
//       for (var cb in WantingStudentsCheckBox) {
//         cb.checked = false;
//       }
//     });
//   }

//   Future<File> _getRanksCacheFile() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final fileName = widget.global ? 'global_ranks.json' : 'halaqa_ranks.json';
//     return File('${directory.path}/$fileName');
//   }

//   Future<void> _saveRanksToCache(List<OneUserRank> ranks) async {
//     try {
//       final file = await _getRanksCacheFile();
//       // print("Attempting to save ranks to: ${file.path}");
//       final List<Map<String, dynamic>> jsonList =
//           ranks.map((r) => r.toJson()).toList();
//       await file.writeAsString(jsonEncode(jsonList));
//       // print("✅ Success: Ranks saved to cache successfully.");
//     } catch (e) {
//       // print("❌ Error: Failed to save ranks to cache: $e");
//     }
//   }

//   Future<void> _loadRanksFromCache() async {
//     try {
//       final file = await _getRanksCacheFile();
//       if (await file.exists()) {
//         final contents = await file.readAsString();
//         if (contents.isNotEmpty) {
//           final List<dynamic> jsonList = jsonDecode(contents);
//           final cachedRanks =
//               jsonList.map((json) => OneUserRank.fromJson(json)).toList();
//           if (mounted) {
//             setState(() {
//               reankMenu = cachedRanks;
//               WantingStudentsCheckBox = reankMenu.map((userRank) {
//                 return WantingCheckBox(checked: false, id: userRank.user_id);
//               }).toList();
//             });
//           }
//           // print("Ranks loaded from cache.");
//         } else {
//           if (mounted) setState(() => reankMenu = []);
//         }
//       } else {
//         // print("Cache file not found.");
//         if (mounted) {
//           showStyledSnackBar(context,
//               message: 'يرجى الاتصال بالإنترنت أولاً لتحميل البيانات',
//               isError: true);
//           setState(() => reankMenu = []);
//         }
//       }
//     } catch (e) {
//       // print("Failed to load ranks from cache: $e");
//       if (mounted) {
//         showStyledSnackBar(context,
//             message: 'حدث خطأ في قراءة البيانات المحلية', isError: true);
//         setState(() => reankMenu = []);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<File> _getPendingAbsencesFile() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return File('${directory.path}/pending_absences.json');
//   }
// // --- تعديل الدالة بالكامل ---
//   Future<void> _saveAbsencesToCache(List<int> studentIds, bool isGlobal) async {
//     try {
//       final file = await _getPendingAbsencesFile();
      
//       // 1. هيكل البيانات الجديد الذي سيتم حفظه
//       Map<String, List<int>> pendingData = {
//         'global': [],
//         'local': []
//       };

//       // 2. قراءة الملف الحالي (إن وجد)
//       if (await file.exists()) {
//         final contents = await file.readAsString();
//         if (contents.isNotEmpty) {
//           final decodedData = jsonDecode(contents) as Map<String, dynamic>;
//           // تحميل القوائم المحفوظة سابقاً بأمان
//           pendingData['global'] = List<int>.from(decodedData['global'] ?? []);
//           pendingData['local'] = List<int>.from(decodedData['local'] ?? []);
//         }
//       }

//       // 3. تحديد القائمة التي سيتم الإضافة إليها
//       final String key = isGlobal ? 'global' : 'local';

//       // 4. إضافة الطلاب الجدد إلى القائمة المناسبة
//       pendingData[key]!.addAll(studentIds);

//       // 5. إزالة التكرار
//       pendingData[key] = pendingData[key]!.toSet().toList();

//       // 6. حفظ الـ Map بالكامل مرة أخرى في الملف
//       await file.writeAsString(jsonEncode(pendingData));
//       // print("Pending absences saved to $key list.");

//     } catch (e) {
//       // print("Failed to save pending absences: $e");
//     }
//   }  
// // --- تعديل الدالة بالكامل ---
//   Future<void> _sendPendingAbsences() async {
//     try {
//       final file = await _getPendingAbsencesFile();
//       if (!await file.exists()) return; // لا يوجد ملف

//       final contents = await file.readAsString();
//       if (contents.isEmpty) return; // ملف فارغ

//       final pendingData = jsonDecode(contents) as Map<String, dynamic>;
//       List<int> globalIds = List<int>.from(pendingData['global'] ?? []);
//       List<int> localIds = List<int>.from(pendingData['local'] ?? []);

//       bool globalSent = false;
//       bool localSent = false;

//       // 1. محاولة إرسال الغياب العام (Global)
//       if (globalIds.isNotEmpty) {
//         try {
//           // print("Sending ${globalIds.length} pending GLOBAL absences...");
//           final success = await _profileProvider.add_wanting_students(globalIds, true); // glob = true
//           if (success) {
//             globalSent = true; // تم الإرسال بنجاح
//             if (mounted) {
//               showStyledSnackBar(context, message: 'تم إرسال الغياب العام المحفوظ سابقاً');
//             }
//           }
//         } catch (e) {
//           // print("Failed to send pending GLOBAL absences: $e");
//           // لا تفعل شيئاً، سيعاد المحاولة في المرة القادمة
//         }
//       }

//       // 2. محاولة إرسال الغياب المحلي (Local)
//       if (localIds.isNotEmpty) {
//         try {
//           // print("Sending ${localIds.length} pending LOCAL absences...");
//           final success = await _profileProvider.add_wanting_students(localIds, false); // glob = false
//           if (success) {
//             localSent = true; // تم الإرسال بنجاح
//             if (mounted) {
//               showStyledSnackBar(context, message: 'تم إرسال غياب الحلقة المحفوظ سابقاً');
//             }
//           }
//         } catch (e) {
//           // print("Failed to send pending LOCAL absences: $e");
//           // لا تفعل شيئاً، سيعاد المحاولة في المرة القادمة
//         }
//       }

//       // 3. تحديث ملف الكاش
//       // (فقط إذا نجحت عملية واحدة على الأقل)
//       if (globalSent || localSent) {
        
//         // بناء البيانات الجديدة (احتفظ فقط بما لم يتم إرساله)
//         Map<String, List<int>> newData = {
//           'global': globalSent ? [] : globalIds, // إذا أُرسلت، قم بتفريغها
//           'local': localSent ? [] : localIds,    // إذا أُرسلت، قم بتفريغها
//         };

//         // إذا أصبحت القائمتان فارغتين، احذف الملف. وإلا، قم بتحديثه.
//         if (newData['global']!.isEmpty && newData['local']!.isEmpty) {
//           await file.delete();
//           // print("Pending absences file cleared.");
//         } else {
//           await file.writeAsString(jsonEncode(newData));
//           // print("Pending absences file updated.");
//         }
//       }
//     } catch (e) {
//       // print("Failed to send pending absences: $e");
//     }
//   }
// // ✅ قم باستبدال هذه الدالة بالكامل في ملفك
//   Widget _buildRankListItem(
//       BuildContext context, int index, User user, bool isOnline) {
//     final currentRankItem = reankMenu[index];
//     final bool showAdminControls =
//         (user.privilege == 3 || user.privilege == 4) ||
//             (user.privilege == 2 && !widget.global);
//     final bool isCurrentUser = currentRankItem.user_id == user.id ||
//         currentRankItem.teacher_id == user.id;

//     // ✅ --- بداية التعديل ---
//     // تحديد الأيقونة واللون بناءً على حالة الحضور الأخيرة
//     final bool isPresent = currentRankItem.lastAttendanceStatus == 'present';
//     final Icon attendanceIcon = isPresent
//         ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
//         : const Icon(Icons.cancel, color: Colors.red, size: 28);
//     final String attendanceTooltip =
//         isPresent ? 'حاضر آخر مرة' : 'غائب آخر مرة';
//     // ✅ --- نهاية التعديل ---

//     return Card(
//       elevation: 1.5,
//       margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//       color: isCurrentUser ? Colors.green.shade50 : Colors.white,
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: isCurrentUser
//             ? const BorderSide(color: Colors.green, width: 1.2)
//             : BorderSide.none,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.person, color: Colors.green),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "الاسم: ${currentRankItem.user_name}",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 // ✅ عرض أيقونة الحضور والغياب هنا
//                 Tooltip(
//                   message: attendanceTooltip,
//                   child: attendanceIcon,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.emoji_events, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 Text(
//                   "المرتبة: ${index + 1}",
//                   style: const TextStyle(fontSize: 15),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.star, color: Colors.amber),
//                 const SizedBox(width: 8),
//                 Text(
//                   "النقاط: ${currentRankItem.points}",
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//             // ✅ --- بداية التعديل ---
//             // إضافة عرض إجمالي أيام الغياب
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.event_busy_outlined, color: Colors.blueGrey),
//                 const SizedBox(width: 8),
//                 Text(
//                   "أيام الغياب: ${currentRankItem.missingDays}",
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Colors.blueGrey,
//                   ),
//                 ),
//               ],
//             ),
//             // ✅ --- نهاية التعديل ---
//             const SizedBox(height: 8),
//             if (showAdminControls) ...[
//               const Divider(), // فاصل بصري
//               Row(
//                 children: [
//                   const Text(
//                     "تسجيل غياب اليوم: ",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Checkbox(
//                     value: WantingStudentsCheckBox.firstWhere(
//                       (item) => item.id == currentRankItem.user_id,
//                       orElse: () => WantingCheckBox(checked: false, id: -1),
//                     ).checked,
//                     onChanged: (value) {
//                       _handleCheckboxChange(value, currentRankItem.user_id);
//                     },
//                     activeColor: Colors.green,
//                   ),
//                   const Spacer(),
//                   popupmenuForRankPage(
//                     user_id: currentRankItem.user_id,
//                     UpdateParent: UpdateScreen,
//                     isOnline: isOnline,
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentDropdownMenu() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Material(
//         child: DropdownMenu<String>(
//           width: screenWidth * 0.9,
//           controller: reankMenucController,
//           hintText: "ابحث عن طالب",
//           enableFilter: true,
//           requestFocusOnTap: true,
//           initialSelection: specificUser?.user_name,
//           label: const Text('اختر طالب'),
//           onSelected: (String? menu) {
//             FocusManager.instance.primaryFocus?.unfocus();
//             try {
//               if (menu == null) {
//                 specificUser = null;
//                 indexOf = -1;
//               } else {
//                 specificUser = reankMenu
//                     .firstWhere((element) => element.user_name == menu);
//                 indexOf = reankMenu.indexOf(specificUser!);
//               }
//               setState(() {});
//             } catch (e) {
//               setState(() {
//                 specificUser = null;
//                 indexOf = -1;
//               });
//             }
//           },
//           dropdownMenuEntries:
//               reankMenu.map<DropdownMenuEntry<String>>((OneUserRank user) {
//             return DropdownMenuEntry<String>(
//               value: user.user_name,
//               label: user.user_name,
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   void _handleCheckboxChange(bool? value, int userId) {
//     if (value == null) return;
//     final checkboxState =
//         WantingStudentsCheckBox.firstWhere((item) => item.id == userId);
//     setState(() {
//       checkboxState.checked = value;
//       if (value) {
//         watingStudents.add(userId);
//       } else {
//         watingStudents.remove(userId);
//       }
//     });
//   }
// }
