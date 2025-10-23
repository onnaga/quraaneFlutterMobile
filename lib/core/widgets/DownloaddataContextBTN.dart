import 'package:flutter/material.dart';
import 'package:masjed/core/utils/my_download_icon.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/profile.dart';

class DownloaddataContextBTN extends StatefulWidget {
  final void Function(BuildContext sendedContext, Profile profile) submit;
  final bool logging;
  final Profile profile;
  final BuildContext sendedContext;

  const DownloaddataContextBTN({
    super.key,
    required this.submit,
    required this.logging,
    required this.profile,
    required this.sendedContext,
  });

  @override
  State<DownloaddataContextBTN> createState() => _DownloaddataContextBTNState();
}

class _DownloaddataContextBTNState extends State<DownloaddataContextBTN> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // منع الضغط المتكرر أثناء التحميل
        if (!widget.logging) {
          widget.submit(widget.sendedContext, widget.profile);
        }
      },
      child: Container(
        width: sizeConfig.defaultSize! * 6,
        height: sizeConfig.defaultSize! * 5,
        alignment: Alignment.center,
        child: widget.logging
            ? const ModernLoader(size: 25) // ✅ عرض اللودر أثناء التحميل
            : const GradientDownloadIcon(size: 45), // ✅ عرض الأيقونة إذا ما في تحميل
      ),
    );
  }
}
