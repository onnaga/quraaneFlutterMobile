import 'package:flutter/material.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/edite_user_test_data.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

// =========================================================================
// 1. الشاشة الرئيسية (Main Screen)
// =========================================================================
class UserTestListViewAccepters extends StatelessWidget {
  final List<TestUserAccepters> dataFromApi;

  const UserTestListViewAccepters({super.key, required this.dataFromApi});

  @override
  Widget build(BuildContext context) {
    final int userPrivilege = Provider.of<User>(context, listen: false).privilege ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "الطلاب المتقدمون للسبر",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: dataFromApi.isEmpty
          ? const Center(
              child: Text(
                "لا يوجد متقدمين بعد",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: dataFromApi.length,
              itemBuilder: (context, index) {
                // ✅ بناء الواجهة بناءً على صلاحية المستخدم
                // لم نعد نستخدم ارتفاعًا ثابتًا، مما يجعل التصميم مرنًا
                if (userPrivilege == 1) {
                  return StudentInfoCard(userInfo: dataFromApi[index]);
                } else {
                  return UserTestEditorForm(initialUserInfo: dataFromApi[index]);
                }
              },
            ),
    );
  }
}

// =========================================================================
// 2. واجهة عرض بيانات الطالب (للمستخدم العادي) - Reusable Card
// =========================================================================
class StudentInfoCard extends StatelessWidget {
  final TestUserAccepters userInfo;

  const StudentInfoCard({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, "اسم الطالب", userInfo.user_name),
            const Divider(height: 20),
            _buildInfoRow(Icons.star, "التقدير", userInfo.rating),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.book, "أرقام الأجزاء", userInfo.the_part_to_test_in),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes, "الملاحظات", userInfo.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}


