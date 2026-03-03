import 'package:flutter/material.dart';
import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsModel news;

  const NewsDetailPage({super.key, required this.news});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open article URL.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 700;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'news_image_${news.id}',
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context2, url) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context2, url, error) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? (width - 700) / 2 : 20,
              vertical: 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.rss_feed_rounded, size: 16),
                      label: Text(news.newsSite),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      backgroundColor:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                    ),
                    Chip(
                      avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                      label: Text(news.publishedAt.split('T').first),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  news.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 20),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  news.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _openUrl(context, news.url),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text(
                    'Read Full Article',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
