import 'package:assignment_news/core/local_storage/database_helper.dart';
import 'package:assignment_news/features/news/data/models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<List<NewsModel>> getCachedNews();
  Future<void> cacheNews(List<NewsModel> news);
  Future<void> clearCache();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final DatabaseHelper db;

  NewsLocalDataSourceImpl({required this.db});

  @override
  Future<List<NewsModel>> getCachedNews() async {
    final rows = await db.getAllNews();
    return rows.map((row) => NewsModel.fromJson(row)).toList();
  }

  @override
  Future<void> cacheNews(List<NewsModel> news) async {
    final rows = news.map((n) => n.toJson()).toList();
    await db.insertNews(rows);
  }

  @override
  Future<void> clearCache() => db.clearNews();
}
