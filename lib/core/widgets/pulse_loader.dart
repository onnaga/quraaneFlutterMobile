import 'package:flutter/material.dart';

class PulseLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const PulseLoader({super.key, this.size = 80, this.color});

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
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
    final color = widget.color ?? const Color.fromARGB(193, 30, 141, 30);

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2 + 0.3 * (1 - _controller.value)),
            ),
            child: Center(
              child: Container(
                width: widget.size * (0.5 + 0.5 * _controller.value),
                height: widget.size * (0.5 + 0.5 * _controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
