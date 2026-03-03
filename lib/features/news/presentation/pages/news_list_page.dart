import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:assignment_news/features/news/data/models/news_model.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_bloc.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_event.dart';
import 'package:assignment_news/features/news/presentation/bloc/news_state.dart';
import 'package:assignment_news/features/news/presentation/pages/news_detail_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(const FetchNewsEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NewsBloc>().add(LoadMoreNewsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, NewsModel news) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NewsDetailPage(news: news),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 700;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Spaceflight News',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context
                  .read<NewsBloc>()
                  .add(const FetchNewsEvent(isRefresh: true));
            },
          ),
        ],
      ),
      body: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              !state.isLoading &&
              !state.isFetchingMore &&
              state.newsList.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.newsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.newsList.isEmpty && state.errorMessage != null) {
            return _ErrorView(
              message: state.errorMessage!,
              onRetry: () => context
                  .read<NewsBloc>()
                  .add(const FetchNewsEvent(isRefresh: true)),
            );
          }

          if (state.newsList.isEmpty) {
            return _EmptyView(
              onRefresh: () => context
                  .read<NewsBloc>()
                  .add(const FetchNewsEvent(isRefresh: true)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NewsBloc>()
                  .add(const FetchNewsEvent(isRefresh: true));
            },
            child: isDesktop
                ? _buildGridView(context, state, width)
                : _buildListView(context, state),
          );
        },
      ),
    );
  }

  Widget _buildListView(BuildContext context, NewsState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount:
          state.hasReachedMax ? state.newsList.length : state.newsList.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.newsList.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final news = state.newsList[index];
        return _AnimatedNewsCard(
          index: index,
          child: _NewsListTile(
            news: news,
            onTap: () => _navigateToDetail(context, news),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, NewsState state, double width) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 1100 ? 4 : (width > 900 ? 3 : 2),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount:
          state.hasReachedMax ? state.newsList.length : state.newsList.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.newsList.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final news = state.newsList[index];
        return _AnimatedNewsCard(
          index: index,
          child: _NewsGridCard(
            news: news,
            onTap: () => _navigateToDetail(context, news),
          ),
        );
      },
    );
  }
}

class _AnimatedNewsCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedNewsCard({required this.index, required this.child});

  @override
  State<_AnimatedNewsCard> createState() => _AnimatedNewsCardState();
}

class _AnimatedNewsCardState extends State<_AnimatedNewsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 400));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _NewsListTile extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const _NewsListTile({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'news_image_${news.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context2, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context2, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.rss_feed_rounded,
                          size: 13,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.newsSite,
                          style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        news.publishedAt.split('T').first,
                        style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsGridCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const _NewsGridCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'news_image_${news.id}',
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context2, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context2, url, error) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40)),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      news.newsSite,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 70,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper_rounded,
                size: 70,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            Text('No articles found',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh and check again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
