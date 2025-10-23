import 'package:flutter/material.dart';

class GradientDownloadIcon extends StatelessWidget {
  final double size;

  const GradientDownloadIcon({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF006400), // أخضر غامق
          Color(0xFF40E0D0), // تركوازي
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(
        Icons.cloud_sync, // أيقونة عصرية بديلة
        size: size,
        color: Colors.white, // اللون يتلون بالتدرج
      ),
    );
  }
}
