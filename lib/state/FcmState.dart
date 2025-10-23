import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Fcmstate {
    String? baseUrl = dotenv.env['BASE_URL'];
  final Dio dio = Dio(BaseOptions(
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// ✅ Function to send the token to your Laravel server
  Future<void> sendFcmTokenToServer(String fcmToken, String userToken) async {
    if (userToken.isEmpty) {
      // print('❌ User auth token is not available. Cannot send FCM token.');
      return;
    }

    final url = '${baseUrl}update-fcm-token';

    try {
      final response = await dio.post(
        url,
        data: json.encode({'fcm_token': fcmToken}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // print('✅ FCM token sent to server successfully.');
      } else {
        // print('❌ Failed to send FCM token. Status: ${response.statusCode}');
        // print('Response Body: ${response.data}');
      }
    } catch (e) {
      // print('❌ Error sending FCM token to server: $e');
    }
  }
}
