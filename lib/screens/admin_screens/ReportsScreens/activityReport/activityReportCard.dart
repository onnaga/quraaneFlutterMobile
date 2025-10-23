import 'package:flutter/material.dart';

class ActivityReportCard extends StatelessWidget {
  final Map<String, dynamic>? oneActivityAchive;

  const ActivityReportCard({super.key, required this.oneActivityAchive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(60, 0, 0, 0),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(3, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.green, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "اسم الإنجاز: ${oneActivityAchive?['name'] ?? ''}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // التقييم
              _buildInfoRow(
                icon: Icons.star,
                label: "تقييم الإنجاز",
                value: "${oneActivityAchive?['mark'] ?? 0}",
                color: Colors.orange,
              ),

              // النقاط
              _buildInfoRow(
                icon: Icons.score,
                label: "النقاط المكتسبة",
                value: "${oneActivityAchive?['point'] ?? 0}",
                color: Colors.blue,
              ),

              // مرات النجاح
              _buildInfoRow(
                icon: Icons.check_circle,
                label: "مرات النجاح",
                value: "${oneActivityAchive?['number_of_repetitions'] ?? 0}",
                color: Colors.green,
              ),

              // مرات الفشل
              _buildInfoRow(
                icon: Icons.cancel,
                label: "مرات الإعادة",
                value: "${oneActivityAchive?['failures'] ?? 0}",
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
