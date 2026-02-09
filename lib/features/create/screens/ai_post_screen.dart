import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/posts_repository.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/services/error_logger.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// AI Post: topic + tone + length -> call generate-post, show 1–3 variants; "Use this" creates post + moderate.
class AiPostScreen extends StatefulWidget {
  const AiPostScreen({super.key});

  @override
  State<AiPostScreen> createState() => _AiPostScreenState();
}

class _AiPostScreenState extends State<AiPostScreen> {
  final _topicController = TextEditingController();
  String _tone = 'neutral';
  String _length = 'short';
  List<String> _variants = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = 'Enter a topic');
      return;
    }
    if (!AppSupabase.isInitialized) {
      setState(() => _error = 'Not connected');
      return;
    }
    setState(() { _loading = true; _error = null; _variants = []; });
    try {
      final res = await AppSupabase.client.functions.invoke(
        'generate-post',
        body: {
          'topic': topic,
          'tone': _tone,
          'target_length': _length,
        },
      );
      final data = res.data as Map<String, dynamic>?;
      final list = data?['variants'] as List?;
      if (list != null && list.isNotEmpty) {
        setState(() => _variants = list.map((e) => e.toString()).toList());
      } else {
        setState(() => _error = 'No variants returned');
      }
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'AiPostScreen._generate', context: {
        'topic': topic,
        'tone': _tone,
        'length': _length,
      });
      setState(() => _error = 'Failed to generate post. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useVariant(String text) async {
    if (text.length > 280) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Variant too long (max 280).')));
      return;
    }
    setState(() => _loading = true);
    final result = await PostsRepository.createPost(body: text);
    if (mounted) {
      setState(() => _loading = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created.')));
        context.go(AppPaths.home);
      } else {
        ErrorLogger.logError('Failed to create post', null, tag: 'AiPostScreen._useVariant', context: {
          'text_length': text.length,
        });
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
                        'create.ai_post'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Topic',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _topicController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'What should the post be about?',
                              hintStyle: TextStyle(color: Colors.white60),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            enabled: !_loading,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _tone,
                            dropdownColor: AppColors.darkBg,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                              DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                              DropdownMenuItem(value: 'professional', child: Text('Professional')),
                            ],
                            onChanged: _loading ? null : (v) => setState(() => _tone = v ?? 'neutral'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Length',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _length,
                            dropdownColor: AppColors.darkBg,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'short', child: Text('Short')),
                              DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            ],
                            onChanged: _loading ? null : (v) => setState(() => _length = v ?? 'short'),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      GlassSurface(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(16),
                        blur: 20,
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: EdgeInsets.zero,
                      blur: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _loading ? null : _generate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Generate variants',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_variants.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'Pick one to post',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._variants.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ContentCard(
                          onTap: _loading ? null : () => _useVariant(v),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  v,
                                  style: theme.textTheme.bodyLarge,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _loading ? null : () => _useVariant(v),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Center(
                                          child: Text(
                                            'Use this',
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
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
