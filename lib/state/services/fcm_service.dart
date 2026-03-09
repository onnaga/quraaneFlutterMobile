import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_client.dart';

class FcmService {
  final Dio _dio = ApiClient().dio;
  final String _baseUrl = ApiClient().baseUrl;

  Future<void> sendFcmTokenToServer(String fcmToken, String userToken) async {
    if (userToken.isEmpty) {
      return;
    }

    final url = '${_baseUrl}update-fcm-token';

    try {
      final response = await _dio.post(
        url,
        data: json.encode({'fcm_token': fcmToken}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        // success
      }
    } catch (e) {
      // error
    }
  }
}
