import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class FetchNewsEvent extends NewsEvent {
  final bool isRefresh;

  const FetchNewsEvent({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}

class LoadMoreNewsEvent extends NewsEvent {}
