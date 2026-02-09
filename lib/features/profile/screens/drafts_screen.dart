import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/local/drafts_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';
import 'package:skrolz_app/widgets/skeleton_loaders.dart';

/// Drafts list screen.
class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List<Draft> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await DraftsRepository.getAllDrafts();
    if (mounted) {
      setState(() {
        _drafts = list;
        _loading = false;
      });
    }
  }

  Future<void> _deleteDraft(String id) async {
    await DraftsRepository.deleteDraft(id);
    _load();
  }

  void _openDraft(Draft draft) {
    if (draft.type == 'post') {
      context.push(AppPaths.writePost, extra: draft.data);
    } else if (draft.type == 'lesson') {
      context.push(AppPaths.createLesson, extra: draft.data);
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(8),
                      blur: 20,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'profile.drafts'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_drafts.isNotEmpty)
                      GlassSurface(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(8),
                        blur: 20,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('drafts.delete_all'.tr()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('drafts.cancel'.tr()),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('drafts.delete'.tr()),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await DraftsRepository.deleteAllDrafts();
                              _load();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _loading
                    ? const ListSkeleton()
                    : _drafts.isEmpty
                        ? Center(
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(24),
                              padding: const EdgeInsets.all(32),
                              blur: 30,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_note, size: 64, color: Colors.white70),
                                  const SizedBox(height: 16),
                                  Text(
                                    'drafts.no_drafts'.tr(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _drafts.length,
                            itemBuilder: (context, i) {
                              final draft = _drafts[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ContentCard(
                                  onTap: () => _openDraft(draft),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          draft.type == 'post' ? Icons.article : Icons.school,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              draft.type == 'post'
                                                  ? (draft.data['body'] as String? ?? 'Untitled post')
                                                  : (draft.data['title'] as String? ?? 'Untitled lesson'),
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(draft.updatedAt ?? draft.createdAt),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.white60,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                        onPressed: () => _deleteDraft(draft.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
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
