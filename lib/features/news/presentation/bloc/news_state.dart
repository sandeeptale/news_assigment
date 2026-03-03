import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:equatable/equatable.dart';

class NewsState extends Equatable {
  final List<NewsModel> newsList;
  final bool isLoading;
  final bool isFetchingMore;
  final String? errorMessage;
  final bool hasReachedMax;

  const NewsState({
    this.newsList = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  NewsState copyWith({
    List<NewsModel>? newsList,
    bool? isLoading,
    bool? isFetchingMore,
    String? errorMessage,
    bool? hasReachedMax,
    bool clearError = false,
  }) {
    return NewsState(
      newsList: newsList ?? this.newsList,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        newsList,
        isLoading,
        isFetchingMore,
        errorMessage,
        hasReachedMax,
      ];
}
