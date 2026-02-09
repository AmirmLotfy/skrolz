import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/notifications_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Notifications: card-based items with glassmorphism, grouped by date.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationRow> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await NotificationsRepository.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await NotificationsRepository.markAsRead(id);
    _load();
  }

  Future<void> _markAllAsRead() async {
    await NotificationsRepository.markAllAsRead();
    _load();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'like':
        return AppColors.accent;
      case 'comment':
        return AppColors.primary;
      case 'follow':
        return AppColors.accentSecondary;
      case 'mention':
        return AppColors.info;
      default:
        return AppColors.textDarkSecondary;
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
                  'notifications.title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
              ),
              actions: _notifications.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GlassSurface(
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(8),
                          blur: 20,
                          child: IconButton(
                            icon: const Icon(Icons.done_all, color: Colors.white),
                            onPressed: _markAllAsRead,
                          ),
                        ),
                      ),
                    ]
                  : null,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: _loading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _notifications.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(24),
                              padding: const EdgeInsets.all(32),
                              blur: 25,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    size: 64,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No notifications yet',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enable push to get streak and digest reminders',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final notif = _notifications[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ContentCard(
                                  onTap: () {
                                    if (!notif.read) _markAsRead(notif.id);
                                    if (notif.contentId != null && notif.contentType != null) {
                                      context.push('${AppPaths.story}/${notif.contentId}?type=${notif.contentType}');
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getColorForType(notif.type).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getIconForType(notif.type),
                                          color: _getColorForType(notif.type),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notif.title,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: notif.read ? FontWeight.normal : FontWeight.w600,
                                                color: notif.read ? Colors.white70 : Colors.white,
                                              ),
                                            ),
                                            if (notif.body != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                notif.body!,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.white60,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(notif.createdAt),
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!notif.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: _notifications.length,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

