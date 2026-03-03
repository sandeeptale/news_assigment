import 'package:assignment_news/core/network/api_client.dart';
import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:dio/dio.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNews({int limit = 10, int offset = 0});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient apiClient;

  NewsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NewsModel>> getNews({int limit = 10, int offset = 0}) async {
    try {
      final res = await apiClient.get(
        'articles',
        params: {'limit': limit, 'offset': offset},
      );

      final List<dynamic> items = res.data['results'] ?? [];
      return items.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to fetch articles: ${e.message}');
    }
  }
}
