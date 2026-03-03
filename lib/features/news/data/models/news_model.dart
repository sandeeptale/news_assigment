import 'package:equatable/equatable.dart';

class NewsModel extends Equatable {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      newsSite: json['news_site'] as String? ?? 'Unknown',
      summary: json['summary'] as String? ?? 'No summary available.',
      publishedAt: json['published_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'image_url': imageUrl,
    'news_site': newsSite,
    'summary': summary,
    'published_at': publishedAt,
  };

  @override
  List<Object?> get props => [id, title, url, imageUrl, newsSite, summary, publishedAt];
}
