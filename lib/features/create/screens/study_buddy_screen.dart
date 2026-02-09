import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/services/error_logger.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Study Buddy (premium): topic or content_id -> call study-buddy, show 2 tips + 1 action + 1 micro-quiz.
class StudyBuddyScreen extends StatefulWidget {
  const StudyBuddyScreen({super.key});

  @override
  State<StudyBuddyScreen> createState() => _StudyBuddyScreenState();
}

class _StudyBuddyScreenState extends State<StudyBuddyScreen> {
  final _topicController = TextEditingController();
  List<String> _tips = [];
  String? _action;
  String? _question;
  List<String> _options = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = 'Enter a topic');
      return;
    }
    if (!AppSupabase.isInitialized) {
      setState(() => _error = 'Not connected');
      return;
    }
    setState(() { _loading = true; _error = null; _tips = []; _action = null; _question = null; _options = []; });
    try {
      final res = await AppSupabase.client.functions.invoke(
        'study-buddy',
        body: {'topic': topic},
      );
      final data = res.data as Map<String, dynamic>?;
      if (data != null) {
        final t = data['tips'] as List?;
        setState(() {
          _tips = t?.map((e) => e.toString()).toList() ?? [];
          _action = data['action'] as String?;
          _question = data['question'] as String?;
          _options = (data['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
        });
      } else {
        setState(() => _error = 'No result');
      }
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'StudyBuddyScreen._fetch', context: {
        'topic': topic,
      });
      setState(() => _error = 'Failed to fetch study tips. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
                        'create.study_buddy'.tr(),
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
                              hintText: 'What do you want to study?',
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
                            onTap: _loading ? null : _fetch,
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
                                        'Get study tips',
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
                    if (_tips.isNotEmpty || _action != null || _question != null) ...[
                      const SizedBox(height: 32),
                      if (_tips.isNotEmpty) ...[
                        Text(
                          'Tips',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._tips.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActionCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(t)),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 24),
                      ],
                      if (_action != null && _action!.isNotEmpty) ...[
                        Text(
                          'Action',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ActionCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.touch_app, color: AppColors.accent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_action!)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_question != null && _question!.isNotEmpty) ...[
                        Text(
                          'Quick quiz',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassSurface(
                          borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.all(20),
                          blur: 25,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _question!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_options.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ..._options.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    '${String.fromCharCode(65 + e.key)}. ${e.value}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                )),
                              ],
                            ],
                          ),
                        ),
                      ],
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
