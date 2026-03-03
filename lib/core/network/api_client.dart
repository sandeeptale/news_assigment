import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioOverride}) : dio = dioOverride ?? Dio() {
    dio.options.baseUrl = 'https://api.spaceflightnewsapi.net/v4/';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: false,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    final response = await dio.get(path, queryParameters: params);
    return response;
  }
}
