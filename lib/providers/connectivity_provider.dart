import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider with ChangeNotifier {
  // القيمة الأولية يجب أن تكون false لضمان أن التطبيق ينتظر أول فحص حقيقي
  bool _isOnline = false; 
  bool get isOnline => _isOnline;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ConnectivityProvider() {
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _initialize();
  }

  Future<void> _initialize() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);

    // تأكد من أن الإشعار بالجاهزية يحدث مرة واحدة فقط
    if (!_isInitialized) {
      _isInitialized = true;
      notifyListeners(); // هذا الإشعار يخبر التطبيق أن يبدأ
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool newStatus = !results.contains(ConnectivityResult.none);

    // ✅ هذا الشرط مهم جدًا لمنع الإشعارات غير الضرورية
    if (newStatus != _isOnline) {
      _isOnline = newStatus;
      notifyListeners();
      // print('✅ Connectivity Status Changed: $_isOnline');
    }
  }

  // ✅ الخطوة الثانية: إضافة دالة للاختبار اليدوي
  void forceOffline(bool force) {
    final bool newStatus = !force; // true means online, false means offline
    if (newStatus != _isOnline) {
      _isOnline = newStatus;
      notifyListeners();
      // print('🧪 FORCED Connectivity Status to: $_isOnline');
    }
  }
}