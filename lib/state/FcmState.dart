import 'services/fcm_service.dart';

class Fcmstate {
  final FcmService _fcmService = FcmService();

  /// ✅ Function to send the token to your Laravel server
  Future<void> sendFcmTokenToServer(String fcmToken, String userToken) async {
    await _fcmService.sendFcmTokenToServer(fcmToken, userToken);
  }
}
