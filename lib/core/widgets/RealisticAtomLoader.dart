import 'dart:math' as math;
import 'package:flutter/material.dart';

class RealisticAtomLoader extends StatefulWidget {
  final double size;
  const RealisticAtomLoader({super.key, this.size = 160});

  @override
  State<RealisticAtomLoader> createState() => _RealisticAtomLoaderState();
}

class _RealisticAtomLoaderState extends State<RealisticAtomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🎨 ألوان محسّنة: درجات أزرق بنفسجي متدرج + نواة متوهجة
  final Color nucleusColor = const Color(0xFF222831);
  final List<Color> electronColors = const [
    Color(0xFF00FFF5), // سماوي متوهج
    Color(0xFFB980F0), // بنفسجي ناعم
    Color(0xFFFFA41B), // برتقالي متوازن
  ];

  final int orbitCount = 4;
  final bool showOrbits = true;

  late List<double> _speedMultipliers;
  late List<double> _dotSizes;
  late List<double> _glowOffsets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _speedMultipliers = [1.0, 1.3, 0.9, 1.6];
    _dotSizes = List.generate(
      orbitCount,
      (i) => (widget.size * 0.055) * (1.0 - i * 0.07) + 2,
    );
    _glowOffsets = List.generate(orbitCount, (i) => math.Random().nextDouble());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _electronColorForIndex(int index) =>
      electronColors[index % electronColors.length];

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return CustomPaint(
            painter: _OrbitPainter(
              orbitCount: orbitCount,
              showOrbits: showOrbits,
              orbitColor: Colors.white.withOpacity(0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildNucleus(size),
                for (int i = 0; i < orbitCount; i++)
                  _buildElectron(
                    size: size,
                    orbitIndex: i,
                    progress: t,
                    speed: _speedMultipliers[i],
                    dotSize: _dotSizes[i],
                    color: _electronColorForIndex(i),
                    glowOffset: _glowOffsets[i],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNucleus(double size) {
    final double nucleusRadius = size * 0.16;
    return Container(
      width: nucleusRadius * 2.4,
      height: nucleusRadius * 2.4,
      alignment: Alignment.center,
      child: Container(
        width: nucleusRadius * 2,
        height: nucleusRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF00ADB5),
              nucleusColor.withOpacity(0.9),
              nucleusColor.withOpacity(0.6),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00ADB5).withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectron({
    required double size,
    required int orbitIndex,
    required double progress,
    required double speed,
    required double dotSize,
    required Color color,
    required double glowOffset,
  }) {
    final center = Offset(size / 2, size / 2);
    final maxRadius = size * 0.42;
    final step = maxRadius / (orbitCount + 0.5);
    final radius = step * (orbitIndex + 1) + orbitIndex * 3.0;
    final angle = (progress * 2 * math.pi * speed) +
        (orbitIndex.isEven ? 0.0 : math.pi / 5);

    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    final glowAlpha = 0.6 + 0.4 * math.sin(2 * math.pi * progress + glowOffset);

    return Positioned(
      left: x - dotSize / 2,
      top: y - dotSize / 2,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(glowAlpha),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(glowAlpha),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final int orbitCount;
  final bool showOrbits;
  final Color orbitColor;

  _OrbitPainter({
    required this.orbitCount,
    required this.showOrbits,
    required this.orbitColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showOrbits) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = orbitColor
      ..isAntiAlias = true;

    final center = size.center(Offset.zero);
    final maxRadius = size.width * 0.42;
    final step = maxRadius / (orbitCount + 0.5);

    for (int i = 0; i < orbitCount; i++) {
      final r = step * (i + 1) + i * 3.0;
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => true;
}
