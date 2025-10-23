import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class UserReport extends StatefulWidget {
  final int user_id;
  final ScrollController? scrollController;

  const UserReport({super.key, this.user_id = 0, this.scrollController});
  const UserReport.forProfile(
      {super.key, required this.user_id, this.scrollController});

  @override
  State<UserReport> createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  bool logging = false;
  Future<void> DownloadData(BuildContext context, Profile profile) async {
    setState(() {
      logging = true;
    });

    int privilege = Provider.of<User>(context, listen: false).privilege!;

    // ✅ استدعاء الدالة الجديدة واستقبال النتيجة كـ Map
    var result = await profile.get_score(privilege, widget.user_id);

    // ✅ التحقق من أن الواجهة ما زالت موجودة قبل عرض SnackBar
    if (mounted) {
      // ✅ التعامل مع الواجهة هنا بناءً على النتيجة

      showStyledSnackBar(context,
          message: result['message'],
          isError: result['success'] ? false : true);

    }

    setState(() {
      logging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);

    return Consumer<Profile>(
      builder: (context, profile, child) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          padding: EdgeInsets.all(sizeConfig.defaultSize! * 1.2),
          child: Column(
            children: [
              /// --- بطاقة النقاط ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.green[50],
                child: Padding(
                  padding: EdgeInsets.all(sizeConfig.defaultSize! * 1.5),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: sizeConfig.defaultSize! * 2,
                        runSpacing: sizeConfig.defaultSize! * 2,
                        children: [
                          PointField(
                              'القرآن', profile.q_points, 'images/quran.png'),
                          PointField(
                              'الحديث', profile.h_points, 'images/hadith.png'),
                          PointField('الأنشطة', profile.a_points,
                              'images/activity.png'),
                          PointField(
                              'عقوبات', profile.l_points, 'images/penalty.png'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          const Text('تحديث البيانات',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DownloaddataContextBTN(
                            submit: DownloadData,
                            logging: logging,
                            profile: profile,
                            sendedContext: context,
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1),
                      Text('مجموع النقاط',
                          style: TextStyle(
                              fontSize: sizeConfig.defaultSize! * 1.8,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[900])),
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: sizeConfig.defaultSize! * 3,
                        backgroundColor: Colors.green[200],
                        child: AnimatedNumber(
                          profile.total_points,
                          font_size: sizeConfig.defaultSize! * 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('أيام الغياب',
                          style: TextStyle(
                              fontSize: sizeConfig.defaultSize! * 1.8,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[900])),
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: sizeConfig.defaultSize! * 2.5,
                        backgroundColor: Colors.red[200],
                        child: Text(
                          '${profile.missing_days}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// --- بطاقة الأجزاء ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.green[50],
                child: Padding(
                  padding: EdgeInsets.all(sizeConfig.defaultSize! * 1.5),
                  child: Column(
                    children: [
                      Text(
                        'الأجزاء التي تم سبرها',
                        style: TextStyle(
                          fontSize: sizeConfig.defaultSize! * 1.8,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: chapters(profile.ended_parts ?? []),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// --- Widget للنقاط ---
class PointField extends StatelessWidget {
  final String title;
  final int value;
  final String image_path;

  const PointField(this.title, this.value, this.image_path, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: sizeConfig.defaultSize! * 3.5,
          backgroundImage: AssetImage(image_path),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: sizeConfig.defaultSize! * 2,
          backgroundColor: Colors.green[200],
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

/// --- Animated Number ---
class AnimatedNumber extends StatefulWidget {
  final int num;
  final double? font_size;
  const AnimatedNumber(this.num, {super.key, this.font_size});

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    animation = IntTween(begin: 0, end: widget.num).animate(controller);
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.num != widget.num) {
      animation =
          IntTween(begin: oldWidget.num, end: widget.num).animate(controller);
      controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Text(
          animation.value.toString(),
          style: TextStyle(
            fontSize: widget.font_size ?? 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// --- قائمة الأجزاء ---
List<Widget> chapters(List<dynamic> list) {
  List<Widget> widgets = [];
  for (int i = 0; i < 30; i++) {
    bool done = list.contains(i + 1);
    widgets.add(Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: done ? Colors.green[400] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        (i + 1).toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: done ? Colors.white : Colors.black87,
        ),
      ),
    ));
  }
  return widgets;
}
