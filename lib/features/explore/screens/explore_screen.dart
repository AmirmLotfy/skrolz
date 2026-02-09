import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Explore: modern category pills, collections, and trending with glassmorphism cards.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['All', 'Tech', 'Science', 'Productivity', 'Design', 'Business', 'Health', 'Learning'];
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Explore',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
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
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => context.push(AppPaths.search),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Category pills
                Text(
                  'Categories',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final isSelected = i == 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GlassSurface(
                          borderRadius: BorderRadius.circular(22),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20 : 16,
                            vertical: 10,
                          ),
                          blur: 20,
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          child: Text(
                            categories[i],
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isSelected ? Colors.white : null,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Collections card
                ActionCard(
                  onTap: () => context.push(AppPaths.collections),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.collections_bookmark, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collections',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Curated playlists',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Trending lessons card
                ActionCard(
                  onTap: () {
                    // Navigate to home screen with trending tab selected
                    context.go(AppPaths.home);
                    // Note: Tab selection would need to be handled via state management
                    // For now, just navigate to home - user can manually select trending tab
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending Lessons',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Popular now',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
