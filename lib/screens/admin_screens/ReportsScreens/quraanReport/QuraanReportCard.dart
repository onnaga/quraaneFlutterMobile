import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';

class QuraanReportCard extends StatelessWidget {
  final Map<String, dynamic>? one_quraan_achive;
  const QuraanReportCard({super.key, required this.one_quraan_achive});

  String _getRecitationTypeName(String? type) {
    if (type == 'ghaiban') return 'غيباً';
    if (type == 'nazaran') return 'نظراً';
    return 'غير محدد'; // قيمة افتراضية
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        shadowColor: Colors.teal.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.shade50,
                Colors.green.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🕌 اسم السورة ونوع التسميع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.teal),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "سورة: ${Quraansoarmanage.soarList[one_quraan_achive?['num']]}",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // عرض نوع التسميع
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRecitationTypeName(one_quraan_achive?['type']),
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // ✅ تقييم + نقاط
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.star_rate,
                    label: "التقييم",
                    value: "${one_quraan_achive?['mark'] ?? 0}",
                    color: Colors.amber.shade700,
                  ),
                  _buildInfoItem(
                    icon: Icons.stars,
                    label: "النقاط",
                    value: "${one_quraan_achive?['point'] ?? 0}",
                    color: Colors.green.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 📖 من / إلى
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.playlist_add_check,
                    label: "من الآية",
                    value: "${one_quraan_achive?['from'] ?? 0}",
                  ),
                  _buildInfoItem(
                    icon: Icons.flag,
                    label: "إلى الآية",
                    value: "${one_quraan_achive?['to'] ?? 0}",
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 🔁 مرات النجاح / الفشل
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.check_circle,
                    label: "مرات النجاح",
                    value: "${one_quraan_achive?['success_repetitions'] ?? 0}",
                    color: Colors.teal,
                  ),
                  _buildInfoItem(
                    icon: Icons.cancel,
                    label: "مرات الإعادة",
                    value: "${one_quraan_achive?['failed_repetitions'] ?? 0}",
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 ويدجت صغير للمعلومة مع أيقونة
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color color = Colors.grey,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "$label: $value",
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}