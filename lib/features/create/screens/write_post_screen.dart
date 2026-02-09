import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/local/drafts_repository.dart';
import 'package:skrolz_app/data/supabase/posts_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Write Post: modern glassmorphism input fields, clean submission flow.
class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _bodyController = TextEditingController();
  bool _loading = false;
  String? _error;
  Timer? _autoSaveTimer;
  String? _draftId;
  Map<String, dynamic>? _initialData;

  @override
  void initState() {
    super.initState();
    // Load draft if passed via route
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) {
      _initialData = extra;
      _bodyController.text = extra['body'] as String? ?? '';
      _draftId = extra['draft_id'] as String?;
    }
    
    // Auto-save draft every 3 seconds
    _bodyController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _autoSave);
  }

  Future<void> _autoSave() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    
    _draftId ??= DateTime.now().millisecondsSinceEpoch.toString();
    await DraftsRepository.saveDraft(Draft(
      id: _draftId!,
      type: 'post',
      data: {'body': body},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _bodyController.removeListener(_onTextChanged);
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      setState(() => _error = 'Enter your post');
      return;
    }
    if (body.length > 280) {
      setState(() => _error = 'Max 280 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await PostsRepository.createPost(body: body);
    if (mounted) {
      setState(() => _loading = false);
      if (result != null) {
        // Delete draft after successful publish
        if (_draftId != null) {
          await DraftsRepository.deleteDraft(_draftId!);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created.')));
        context.go(AppPaths.home);
      } else {
        setState(() => _error = 'Failed to create post');
      }
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'create.write_post'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'common.save'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassSurface(
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.all(16),
                        blur: 25,
                        child: TextField(
                          controller: _bodyController,
                          maxLines: null,
                          minLines: 8,
                          maxLength: 280,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind?',
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textDarkSecondary,
                            ),
                            border: InputBorder.none,
                            counterStyle: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textDarkSecondary,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          enabled: !_loading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        GlassSurface(
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.all(12),
                          blur: 20,
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'create.publish'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
