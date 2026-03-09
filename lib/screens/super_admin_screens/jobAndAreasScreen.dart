// ✅ ملف جديد: jobs_and_areas_screen.dart

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class JobsAndAreasScreen extends StatefulWidget {
  const JobsAndAreasScreen({super.key});

  @override
  State<JobsAndAreasScreen> createState() => _JobsAndAreasScreenState();
}

class _JobsAndAreasScreenState extends State<JobsAndAreasScreen> {
  late Future<Map<String, List<dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();

    // استدعاء دالة جلب البيانات عند بدء تشغيل الصفحة
    _dataFuture = Provider.of<Daorastate>(context, listen: false)
        .getJobsAndAreas(Provider.of<User>(context, listen: false).token);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // لدينا تبويبين: الأعمال والمناطق
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأعمال والمناطق'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.work), text: 'الأعمال'),
              Tab(icon: Icon(Icons.location_city), text: 'المناطق'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<dynamic>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            // حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: ModernLoader());
            }
            // حالة وجود خطأ
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }
            // حالة نجاح جلب البيانات
            if (snapshot.hasData) {
              final jobs = snapshot.data!['jobs']!;
              final areas = snapshot.data!['areas']!;

              return TabBarView(
                children: [
                  _buildList(jobs, "عمل"), // عرض قائمة الأعمال
                  _buildList(areas, "منطقة"), // عرض قائمة المناطق
                ],
              );
            }
            // حالة عدم وجود بيانات
            return const Center(child: Text('لا توجد بيانات لعرضها.'));
          },
        ),
      ),
    );
  }

  // ✅ ويدجت قابلة لإعادة الاستخدام لعرض القوائم
  Widget _buildList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return Center(child: Text('لا توجد $typeات لعرضها.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                // عرض عدد المستخدمين
                item['user_count'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(item['name']),
            subtitle: Text('عدد المستخدمين في هذا الـ$type'),
          ),
        );
      },
    );
  }
}
