import 'package:flutter/material.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/quraanReport/QuraanReportCard.dart';

class QuraanReports extends StatelessWidget {
  // البيانات الآن هي Map وليست List
  final Map<String, dynamic>? ended_quraan_this_course;
  const QuraanReports({super.key, required this.ended_quraan_this_course});

  @override
  Widget build(BuildContext context) {
    // استخراج القوائم مع التحقق من أنها ليست null
    final List<dynamic> ghaibanList = ended_quraan_this_course?['ghaiban'] ?? [];
    final List<dynamic> nazaranList = ended_quraan_this_course?['nazaran'] ?? [];

    return DefaultTabController(
      length: 2, // عدد التبويبات
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقرير إنجاز القرآن'),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'غيباً'),
              Tab(text: 'نظراً من المصحف'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: غيباً
            _buildReportList(ghaibanList, 'لا يوجد إنجازات "غيباً" حتى الآن.'),
            
            // التبويب الثاني: نظراً
            _buildReportList(nazaranList, 'لا يوجد إنجازات "نظراً" حتى الآن.'),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء قائمة الإنجازات
  Widget _buildReportList(List<dynamic> reportList, String emptyMessage) {
    if (reportList.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: reportList.length,
      itemBuilder: (context, index) {
        // عكس القائمة لعرض الأحدث أولاً
        return QuraanReportCard(
          one_quraan_achive: reportList[reportList.length - index - 1],
        );
      },
    );
  }
}