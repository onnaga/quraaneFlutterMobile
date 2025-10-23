import 'package:flutter/material.dart';

class Grade extends StatefulWidget {
  final int grade; // من 0 إلى 100
  const Grade(this.grade, {super.key});

  @override
  State<Grade> createState() => _GradeState();
}

class _GradeState extends State<Grade> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // تحريك لمعان النجوم
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double starFill = (widget.grade / 100) * 5;
    final String gradeText = _gradeText(widget.grade);
    final String emoji = _gradeEmoji(widget.grade);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الرقم
        Text(
          "${widget.grade} / 100",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _gradeColor(widget.grade),
          ),
        ),
        const SizedBox(height: 4),
        // النجوم المتحركة
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  if (starFill >= index + 1) {
                    return _shinyStar(Icons.star, _gradeColor(widget.grade));
                  } else if (starFill > index && starFill < index + 1) {
                    return _shinyStar(Icons.star_half, _gradeColor(widget.grade));
                  } else {
                    return _shinyStar(Icons.star_border, Colors.grey.shade400);
                  }
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        // النص مع السمايل
        Text(
          "$emoji $gradeText",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _gradeColor(widget.grade),
          ),
        ),
      ],
    );
  }

  String _gradeText(int grade) {
    if (grade >= 98) return "ممتاز";
    if (grade >= 90) return "جيد جداً";
    if (grade >= 85) return "جيد";
    if (grade >= 80) return "وسط";
    return "إعادة";
  }

  Color _gradeColor(int grade) {
    if (grade >= 98) return Colors.green.shade700;
    if (grade >= 90) return Colors.blue.shade700;
    if (grade >= 85) return Colors.orange.shade700;
    if (grade >= 80) return Colors.brown.shade700;
    return Colors.red.shade700;
  }

  String _gradeEmoji(int grade) {
    if (grade >= 98) return "🌟";       // ممتاز
    if (grade >= 90) return "👍";       // جيد جداً
    if (grade >= 85) return "🙂";       // جيد
    if (grade >= 80) return "😐";       // وسط
    return "🔄";                        // إعادة
  }

  Widget _shinyStar(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Icon(
        icon,
        color: color,
        size: 18,
        shadows: [
          Shadow(
            blurRadius: 2,
            color: color.withOpacity(0.6),
            offset: const Offset(1, 1),
          ),
          Shadow(
            blurRadius: 4,
            color: color.withOpacity(0.3),
            offset: const Offset(-1, -1),
          ),
        ],
      ),
    );
  }
}
