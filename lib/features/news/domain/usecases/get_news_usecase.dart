import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:assignment_news/features/news/domain/repositories/news_repository.dart';

class GetNewsUseCase {
  final NewsRepository repository;

  GetNewsUseCase(this.repository);

  Future<List<NewsModel>> call({bool forceRefresh = false, int limit = 10, int offset = 0}) async {
    return await repository.getNews(
      forceRefresh: forceRefresh,
      limit: limit,
      offset: offset,
    );
  }
}
