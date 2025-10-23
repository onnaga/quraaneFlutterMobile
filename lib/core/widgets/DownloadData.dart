import 'package:flutter/material.dart';
import 'package:masjed/core/utils/my_download_icon.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/profile.dart';

class DownloaddataBTN extends StatefulWidget {
  final void Function(Profile profile) submit;
  final bool logging;
  final Profile profile;

  const DownloaddataBTN({
    super.key,
    required this.submit,
    required this.logging,
    required this.profile,
  });

  @override
  State<DownloaddataBTN> createState() => _DownloaddataBTNState();
}

class _DownloaddataBTNState extends State<DownloaddataBTN> {
  @override
  Widget build(BuildContext context) {
    // sizeConfig().init(context); // تأكد من استدعاء هذا في مكان مناسب
    return GestureDetector(
      onTap: () {
        // منع الضغط المتكرر أثناء التحميل
        if (!widget.logging) {
          widget.submit(widget.profile);
        }
      },
      child: Container(
        // استخدام Container لتوحيد الحجم في الحالتين
        width: sizeConfig.defaultSize! * 6,
        height: sizeConfig.defaultSize! * 5,
        alignment: Alignment.center,
        child: widget.logging
            ? const ModernLoader(size: 25) // ✅ الصحيح: عرض اللودر عندما تكون logging = true
            : const GradientDownloadIcon(size: 50), // ✅ الصحيح: عرض الأيقونة عندما تكون logging = false
      ),
    );
  }
}