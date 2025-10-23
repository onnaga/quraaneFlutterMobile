import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const ModernLoader({super.key, this.size = 60, this.color});

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? const Color.fromARGB(193, 30, 141, 30);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LoaderPainter(
              progress: _controller.value,
              color: themeColor,
            ),
          );
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoaderPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    final radius = size.width / 2.2;
    final startAngle = -progress * 2 * math.pi; // حركة مع عقارب الساعة
    const sweepAngle = math.pi * 0.8;

    // رسم القوس
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // ✅ النقطة عند بداية القوس (وليس النهاية)
    final dotPaint = Paint()..color = color;
    final dotX = size.width / 2 + radius * math.cos(startAngle);
    final dotY = size.height / 2 + radius * math.sin(startAngle);
    canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) => true;
}
