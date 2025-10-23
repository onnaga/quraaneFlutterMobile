import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/core/widgets/setting/settingRoot.dart';
import 'package:masjed/models/notification_model.dart';
import 'package:masjed/providers/notification_provider.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/AdminsManagment.dart';
import 'package:masjed/screens/admin_screens/ReportsScreens/ReportsScreen.dart';
import 'package:masjed/screens/admin_screens/testsScreens/TestsRoot.dart';
import 'package:masjed/screens/user_Ranking_screen/user_ranking.dart';
import 'package:masjed/state/FcmState.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class AdminApp extends StatelessWidget {
  PageController controller = PageController(initialPage: 0, keepPage: true);
  GlobalKey<BarState> bar_state = GlobalKey<BarState>();
  GlobalKey<NavigationState> nav_state = GlobalKey<NavigationState>();

  AdminApp({super.key});




  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context, listen: false);
// print('inside admin app user is  : $user');
// print('inside admin app daora is  : ');
    return PopScope(
      canPop: false,
      onPopInvoked: (f) {
        if (controller.page != 0) {
          controller.animateToPage(0,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
          return;
        }
        // showDialog(
        //     context: context,
        //     barrierDismissible: true,
        //     builder: (context) => ExitAlert());
      },
      child: Scaffold(
        appBar: Bar(key: bar_state ),
        body: PageView(
          onPageChanged: (int i) {
            nav_state.currentState?.update(i);
            bar_state.currentState?.update(i);
          },
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: [
            AdminsManagment(),
            const UserRanking(),
            TestsRoot(privilege: user.privilege!),
            const ReportsScreen(),
          ],
        ),
        bottomNavigationBar: Navigation(controller, key: nav_state),
      ),
    );
  }
}

class Bar extends StatefulWidget implements PreferredSizeWidget {
  
   const Bar({super.key });

  @override
  State<Bar> createState() => BarState();

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class BarState extends State<Bar> {
  int index = 0;
  static bool _isFcmInitialized = false;

  @override
  void initState() {
    super.initState();
    if (!_isFcmInitialized) {
      _isFcmInitialized = true;
      final user = Provider.of<User>(context, listen: false);
      _initFcm(user.token!);
    }
  }
  void update(int i) {
    setState(() {
      index = i;
    });
  }

  static final Map<int, String> pageTitle = {
    0: 'إدارة المستخدمين',
    1: 'المراتب',
    2: 'الاختبارات',
    3: 'التقارير',
  };


void _initFcm (String token )async{
        // ✅ بعد تسجيل الدخول، جيب الإشعارات
final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
await notificationProvider.fetchNotifications(token);
      // ✅ After successful login, initialize notifications
      _initializeFirebaseMessaging(token);
}


 void _initializeFirebaseMessaging(String token) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print('✅ Notification permission granted.');
      final fcmToken = await messaging.getToken();
      
      if (fcmToken != null) {
        // print('📱 FCM Token: $fcmToken');
        // ✅ استعمل Fcmstate
        final fcmState = Fcmstate();
        await fcmState.sendFcmTokenToServer(fcmToken,token);
      }
    } else {
      // print('❌ Notification permission denied.');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('إشعار جديد والتطبيق مفتوح: ${message.notification?.title}');
      // TODO: تحديث UI حسب الحاجة
    });
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
             Color.fromARGB(255, 21, 81, 25),
             Color.fromARGB(255, 11, 136, 105),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // ⚙️ زر الإعدادات
        leading: IconButton(
          icon: const Icon(Icons.settings, size: 28, color: Colors.white),
          splashRadius: 24,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => settingRoot(user: user),
              ),
            );
          },
        ),
        // 📝 العنوان
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            pageTitle[index] ?? '',
            key: ValueKey(pageTitle[index]),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 21,
              letterSpacing: 1.1,
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black38,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        // 🔔 الإشعارات
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return PopupMenuButton<NotificationModel>(
                onSelected: (notification) {
                  // TODO: التنقل لتفاصيل الإشعار
                  debugPrint('Tapped on notification: ${notification.id}');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 8,
                offset: const Offset(0, 55),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${notificationProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  if (notificationProvider.isLoading) {
                    return [
                      const PopupMenuItem(
                        child: Center(child: ModernLoader()),
                      ),
                    ];
                  }
                  if (notificationProvider.notifications.isEmpty) {
                    return [
                      const PopupMenuItem(
                        enabled: false,
                        child: Text('لا توجد إشعارات'),
                      ),
                    ];
                  }

                  // ✅ اجعلها مقروءة عند الفتح
                  notificationProvider.markAllAsRead(user.token!);

                  return notificationProvider.notifications.map((notification) {
                    return PopupMenuItem<NotificationModel>(
                      value: notification,
                      padding: const EdgeInsets.all(0),
                      child:Card(
  elevation: notification.isUnread ? 3 : 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: notification.isUnread
      ? Colors.teal.withOpacity(0.08)
      : Colors.grey.shade50,
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    title: Text(
      notification.title,
      style: TextStyle(
        fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
        fontSize: 14.5,
        color: Colors.black87,
      ),
    ),
    
    // ✅ --- بداية التعديل ---
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // المحتوى
        Text(
          notification.body,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        // عرض الفوتر فقط إذا كان موجودًا
        if (notification.footer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              notification.footer,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    ),
    // --- نهاية التعديل ---

    leading: Icon(
      notification.isUnread ? Icons.markunread : Icons.drafts,
      color: notification.isUnread ? Colors.teal : Colors.grey,
    ),
  ),
)
                    );
                  }).toList();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class Navigation extends StatefulWidget {
  final PageController controller;
  const Navigation(this.controller, {super.key});

  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int index = 0;

  void update(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        widget.controller.animateToPage(i,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      },
      items: const [
        BottomNavigationBarItem(
            label: 'إدارة المستخدمين', icon: Icon(Icons.accessibility_rounded)),
        BottomNavigationBarItem(
            label: 'الأخيرة', icon: Icon(Icons.timelapse_rounded)),
        BottomNavigationBarItem(
            label: 'الاختبارات', icon: Icon(Icons.text_snippet_rounded)),
        BottomNavigationBarItem(
            label: 'التقارير', icon: Icon(Icons.data_exploration_rounded)),
      ],
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black38,
      showUnselectedLabels: true,
    );
  }
}
