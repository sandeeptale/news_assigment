import 'package:assignment_news/features/news/data/models/news_model.dart';

abstract class NewsRepository {
  Future<List<NewsModel>> getNews({bool forceRefresh = false, int limit = 10, int offset = 0});
}
