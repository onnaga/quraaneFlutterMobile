import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  late final String baseUrl;

  ApiClient._internal() {
    baseUrl = dotenv.env['BASE_URL'] ?? "http://127.0.0.1:8000/api/";
    dio = Dio(BaseOptions(
      headers: {
        'content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
}
