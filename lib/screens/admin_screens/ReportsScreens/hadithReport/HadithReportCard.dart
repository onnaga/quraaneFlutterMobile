import 'package:flutter/material.dart';

class HadithReportCard extends StatelessWidget {
  final Map<String, dynamic>? oneHadithAchive;
  const HadithReportCard({super.key, required this.oneHadithAchive});

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
              // رقم الحديث
              _buildInfoRow(
                icon: Icons.format_list_numbered,
                label: "رقم الحديث",
                value: "${oneHadithAchive?['num'] ?? ''}",
                color: Colors.blueGrey,
              ),

              const Divider(height: 20, thickness: 1),

              // تقييم
              _buildInfoRow(
                icon: Icons.star,
                label: "تقييم التسميع",
                value: "${oneHadithAchive?['mark'] ?? 0}",
                color: Colors.orange,
              ),

              // النقاط
              _buildInfoRow(
                icon: Icons.score,
                label: "النقاط المكتسبة",
                value: "${oneHadithAchive?['point'] ?? 0}",
                color: Colors.blue,
              ),

              // // من السطر
              // _buildInfoRow(
              //   icon: Icons.arrow_downward,
              //   label: "من السطر",
              //   value: "${oneHadithAchive?['from'] ?? ''}",
              //   color: Colors.teal,
              // ),

              // // إلى السطر
              // _buildInfoRow(
              //   icon: Icons.arrow_upward,
              //   label: "إلى السطر",
              //   value: "${oneHadithAchive?['to'] ?? ''}",
              //   color: Colors.teal,
              // ),

              // مرات النجاح
              _buildInfoRow(
                icon: Icons.check_circle,
                label: "مرات النجاح",
                value: "${oneHadithAchive?['success_repetitions'] ?? 0}",
                color: Colors.green,
              ),

              // مرات الفشل
              _buildInfoRow(
                icon: Icons.cancel,
                label: "مرات الإعادة",
                value: "${oneHadithAchive?['failed_repetitions'] ?? 0}",
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
