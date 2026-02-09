import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/collections_repository.dart';
import 'package:skrolz_app/features/collections/models/collection.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Collections: grid layout with glassmorphism covers and play button overlays.
class CollectionsListScreen extends ConsumerStatefulWidget {
  const CollectionsListScreen({super.key});

  @override
  ConsumerState<CollectionsListScreen> createState() => _CollectionsListScreenState();
}

class _CollectionsListScreenState extends ConsumerState<CollectionsListScreen> {
  List<Collection> _collections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await CollectionsRepository.getCollections();
    if (mounted) {
      setState(() {
        _collections = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'collections.title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: _loading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _collections.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(24),
                              padding: const EdgeInsets.all(32),
                              blur: 25,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.collections_bookmark, size: 64, color: Colors.white70),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No collections yet',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final c = _collections[i];
                              return ContentCard(
                                onTap: () => context.push('${AppPaths.collectionPlay.replaceAll(':id', c.id)}', extra: c),
                                padding: EdgeInsets.zero,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Cover image or gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: i % 2 == 0
                                            ? AppColors.primaryGradient
                                            : AppColors.accentGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: c.coverUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(
                                                c.coverUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  decoration: BoxDecoration(
                                                    gradient: i % 2 == 0
                                                        ? AppColors.primaryGradient
                                                        : AppColors.accentGradient,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.collections_bookmark,
                                              size: 48,
                                              color: Colors.white,
                                            ),
                                    ),
                                    // Overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            c.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            c.description ?? '${c.itemIds.length} items',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Play button
                                    Center(
                                      child: GlassSurface(
                                        borderRadius: BorderRadius.circular(24),
                                        padding: const EdgeInsets.all(12),
                                        blur: 25,
                                        child: const Icon(
                                          Icons.play_arrow,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                },
                childCount: _collections.length,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
