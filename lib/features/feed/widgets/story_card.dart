import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';
import 'package:skrolz_app/theme/chip_style.dart';
import 'package:skrolz_app/theme/theme.dart';

/// One story card (post or lesson) — typographic, full-screen.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.item,
    this.onTapTopRight,
    this.onTapBottom,
    this.focusMode = false,
  });

  final FeedItem item;
  final VoidCallback? onTapTopRight;
  final VoidCallback? onTapBottom;
  final bool focusMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPost = item.contentType == 'post';
    final headline = isPost ? (item.body ?? '') : (item.title ?? '');
    final subline = item.whyShown;

    return Semantics(
      label: 'Story card: ${headline.length > 50 ? "${headline.substring(0, 50)}..." : (headline.isEmpty ? "Empty" : headline)}',
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.all(focusMode ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  headline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    height: focusMode ? 1.6 : 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subline != null && subline.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (subline.toLowerCase().contains('curated') || subline.toLowerCase().contains('ai'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          subline,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: focusMode ? 1.55 : 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (!focusMode && (item.difficulty != null || item.timeToReadSec != null)) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.difficulty != null)
                        StoryChip(label: item.difficulty!, icon: Icons.bar_chart),
                      if (item.timeToReadSec != null)
                        StoryChip(
                          label: '${(item.timeToReadSec! / 60).ceil()} min read',
                          icon: Icons.schedule,
                        ),
                    ],
                  ),
                ],
                const Spacer(flex: 3),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapTopRight,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                onTapBottom?.call();
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}
