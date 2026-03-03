import 'package:assignment_news/features/news/domain/usecases/get_news_usecase.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_event.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNewsUseCase getNewsUseCase;

  static const _pageSize = 10;
  int _currentOffset = 0;

  NewsBloc({required this.getNewsUseCase}) : super(const NewsState()) {
    on<FetchNewsEvent>(_onFetch);
    on<LoadMoreNewsEvent>(_onLoadMore);
  }

  Future<void> _onFetch(FetchNewsEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _currentOffset = 0;
      final articles = await getNewsUseCase(
        forceRefresh: event.isRefresh,
        limit: _pageSize,
        offset: _currentOffset,
      );

      emit(state.copyWith(
        isLoading: false,
        newsList: articles,
        hasReachedMax: articles.length < _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onLoadMore(LoadMoreNewsEvent event, Emitter<NewsState> emit) async {
    if (state.hasReachedMax || state.isFetchingMore || state.isLoading) return;

    emit(state.copyWith(isFetchingMore: true, clearError: true));

    try {
      _currentOffset += _pageSize;
      final moreArticles = await getNewsUseCase(
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (moreArticles.isEmpty) {
        emit(state.copyWith(isFetchingMore: false, hasReachedMax: true));
      } else {
        emit(state.copyWith(
          isFetchingMore: false,
          newsList: [...state.newsList, ...moreArticles],
        ));
      }
    } catch (e) {
      _currentOffset -= _pageSize;
      emit(state.copyWith(
        isFetchingMore: false,
        errorMessage: _cleanError(e),
      ));
    }
  }

  String _cleanError(Object e) => e.toString().replaceAll('Exception: ', '');
}
