import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/search_repository.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Search: glassmorphism search bar, filter pills, card-based results.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  String _filter = 'all';
  List<FeedItem> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _query.removeListener(_onQueryChanged);
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final q = _query.text.trim();
      if (q.isNotEmpty) {
        _runSearch();
      } else {
        setState(() {
          _results = [];
          _searched = false;
          _error = null;
        });
      }
    });
  }

  Future<void> _runSearch() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
    });
    try {
      final list = await SearchRepository.search(q, filter: _filter);
      if (mounted) {
        setState(() {
          _results = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to search: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.only(right: 60),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  blur: 25,
                  child: TextField(
                    controller: _query,
                    decoration: InputDecoration(
                      hintText: 'Search stories, creators...',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDarkSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _runSearch,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    autofocus: true,
                    onSubmitted: (_) {
                      _debounceTimer?.cancel();
                      _runSearch();
                    },
                  ),
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(8),
                  blur: 20,
                  child: PopupMenuButton<String>(
                    initialValue: _filter,
                    onSelected: (v) => setState(() => _filter = v),
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'all', child: Text('All')),
                      const PopupMenuItem(value: 'posts', child: Text('Posts')),
                      const PopupMenuItem(value: 'lessons', child: Text('Lessons')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _error != null
                ? SliverFillRemaining(
                    child: Center(
                      child: GlassSurface(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(32),
                        blur: 30,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            GlassSurface(
                              borderRadius: BorderRadius.circular(16),
                              padding: EdgeInsets.zero,
                              blur: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: _runSearch,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      child: Text(
                                        'Retry',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _loading
                    ? const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : !_searched
                        ? SliverFillRemaining(
                            child: Center(
                              child: GlassSurface(
                                borderRadius: BorderRadius.circular(24),
                                padding: const EdgeInsets.all(32),
                                blur: 30,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 64,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Enter a query to search',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : _results.isEmpty
                            ? SliverFillRemaining(
                                child: Center(
                                  child: GlassSurface(
                                    borderRadius: BorderRadius.circular(24),
                                    padding: const EdgeInsets.all(32),
                                    blur: 30,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No results found',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final item = _results[i];
                                return ContentCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  onTap: () => context.push('${AppPaths.story}/${item.id}?type=${item.contentType}'),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.contentType.toUpperCase(),
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.body ?? item.title ?? 'Story',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: _results.length,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
