import 'package:assignment_news/features/news/data/datasources/news_local_data_source.dart';
import 'package:assignment_news/features/news/data/datasources/news_remote_data_source.dart';
import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:assignment_news/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<NewsModel>> getNews({
    bool forceRefresh = false,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final freshData = await remoteDataSource.getNews(limit: limit, offset: offset);

      if (offset == 0) {
        await localDataSource.clearCache();
        await localDataSource.cacheNews(freshData);
      }

      return freshData;
    } catch (e) {
      if (offset == 0) {
        final cached = await localDataSource.getCachedNews();
        if (cached.isNotEmpty) return cached;
      }
      rethrow;
    }
  }
}
