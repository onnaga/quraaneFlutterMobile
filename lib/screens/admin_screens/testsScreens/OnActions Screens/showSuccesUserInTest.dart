import 'package:flutter/material.dart';

import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/edite_user_test_data.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';



// الويدجت الرئيسية لعرض نتائج الاختبار
class Showsuccesuserintest extends StatelessWidget {
  final List<TestUserAccepters> successUsers;
  final List<TestUserAccepters> failUsers;

  const Showsuccesuserintest({
    super.key,
    required this.successUsers,
    required this.failUsers,
  });

  @override
  Widget build(BuildContext context) {
    // الحصول على صلاحيات المستخدم وآي ديه
    final user = Provider.of<User>(context, listen: false);
    final userPrivilege = user.privilege;
    final userId = user.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 4,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "نتائج الاختبار",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(200, 230, 230, 230),
            tabs: [
              Tab(icon: Icon(Icons.check_circle_outline), text: 'الناجحين'),
              Tab(icon: Icon(Icons.cancel_outlined), text: 'غير الناجحين'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UsersListScreen(
              users: successUsers,
              privilege: userPrivilege,
              currentUserId: userId!,
              emptyListMessage: "لا يوجد طلاب ناجحون....",
            ),
            _UsersListScreen(
              users: failUsers,
              privilege: userPrivilege,
              currentUserId: userId,
              emptyListMessage: "لا يوجد طلاب غير ناجحين....",
            ),
          ],
        ),
      ),
    );
  }
}

// ويدجت موحدة لعرض قائمة المستخدمين
class _UsersListScreen extends StatelessWidget {
  final List<TestUserAccepters> users;
  final int? privilege;
  final int currentUserId;
  final String emptyListMessage;

  const _UsersListScreen({
    required this.users,
    required this.privilege,
    required this.currentUserId,
    required this.emptyListMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyListMessage,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return privilege == 1
            ? _StudentInfoView(
                userInfo: user,
                highlight: user.user_id == currentUserId,
              )
            : UserTestEditorForm(
                initialUserInfo: user,
              );
      },
    );
  }
}

// واجهة عرض معلومات الطالب
class _StudentInfoView extends StatelessWidget {
  final TestUserAccepters userInfo;
  final bool highlight;

  const _StudentInfoView({required this.userInfo, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: highlight
              ? const LinearGradient(
                  colors: [Colors.teal, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "👤 ${userInfo.user_name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: highlight ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "التقدير: ${userInfo.rating}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: highlight ? Colors.white : Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "📖 الأجزاء: ${userInfo.the_part_to_test_in}",
              style: TextStyle(
                color: highlight ? Colors.white70 : Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "📝 الملاحظات: ${userInfo.notes}",
              style: TextStyle(
                color: highlight ? Colors.white70 : Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
