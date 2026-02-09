import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/local/drafts_repository.dart';
import 'package:skrolz_app/data/supabase/lesson_repository.dart';
import 'package:skrolz_app/router/app_router.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Create Lesson (premium): title, sections (title/body/image/key_takeaway), optional quiz; insert + moderate.
class CreateLessonScreen extends StatefulWidget {
  const CreateLessonScreen({super.key});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _titleController = TextEditingController();
  final List<Map<String, String?>> _sections = [
    {'title': null, 'body': null, 'image_url': null, 'key_takeaway': null},
    {'title': null, 'body': null, 'image_url': null, 'key_takeaway': null},
  ];
  String? _quizQuestion;
  final List<TextEditingController> _quizOptionControllers = [TextEditingController(), TextEditingController()];
  int _correctIndex = 0;
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
      _titleController.text = extra['title'] as String? ?? '';
      _quizQuestion = extra['quiz_question'] as String?;
      if (extra['sections'] is List) {
        final sections = extra['sections'] as List;
        for (int i = 0; i < sections.length && i < _sections.length; i++) {
          final s = sections[i] as Map<String, dynamic>;
          _sections[i] = {
            'title': s['title'] as String?,
            'body': s['body'] as String?,
            'image_url': s['image_url'] as String?,
            'key_takeaway': s['key_takeaway'] as String?,
          };
        }
      }
      if (extra['quiz_options'] is List) {
        final opts = extra['quiz_options'] as List;
        for (int i = 0; i < opts.length && i < _quizOptionControllers.length; i++) {
          _quizOptionControllers[i].text = opts[i] as String? ?? '';
        }
      }
      _correctIndex = extra['correct_index'] as int? ?? 0;
      _draftId = extra['draft_id'] as String?;
    }
    
    // Auto-save draft every 5 seconds
    _titleController.addListener(_onContentChanged);
    for (final c in _quizOptionControllers) {
      c.addListener(_onContentChanged);
    }
  }

  void _onContentChanged() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 5), _autoSave);
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    
    _draftId ??= DateTime.now().millisecondsSinceEpoch.toString();
    final sections = _sections.map((s) => {
      'title': s['title'],
      'body': s['body'],
      'image_url': s['image_url'],
      'key_takeaway': s['key_takeaway'],
    }).toList();
    
    await DraftsRepository.saveDraft(Draft(
      id: _draftId!,
      type: 'lesson',
      data: {
        'title': title,
        'sections': sections,
        'quiz_question': _quizQuestion,
        'quiz_options': _quizOptionControllers.map((c) => c.text).toList(),
        'correct_index': _correctIndex,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.removeListener(_onContentChanged);
    for (final c in _quizOptionControllers) {
      c.removeListener(_onContentChanged);
    }
    _titleController.dispose();
    for (final c in _quizOptionControllers) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Enter a title');
      return;
    }
    final sections = <Map<String, dynamic>>[];
    for (final s in _sections) {
      final rawBody = s['body'];
      final String body = rawBody is String ? rawBody.trim() : '';
      if (body.isEmpty) {
        continue;
      }
      sections.add({
        'title': s['title']?.trim(),
        'body': body,
        'image_url': s['image_url']?.trim(),
        'key_takeaway': s['key_takeaway']?.trim(),
      });
    }
    if (sections.isEmpty) {
      setState(() => _error = 'Add at least one section with body');
      return;
    }
    final quizQuestions = <Map<String, dynamic>>[];
    final q = _quizQuestion?.trim();
    if (q != null && q.isNotEmpty) {
      final opts = _quizOptionControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
      if (opts.length >= 2) {
        quizQuestions.add({'question': q, 'options': opts, 'correct_index': _correctIndex});
      }
    }
    setState(() { _loading = true; _error = null; });
    final id = await LessonRepository.createLesson(
      title: title,
      sections: sections,
      quizQuestions: quizQuestions,
    );
    if (mounted) {
      setState(() => _loading = false);
      if (id != null) {
        // Delete draft after successful publish
        if (_draftId != null) {
          await DraftsRepository.deleteDraft(_draftId!);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson created.')));
        context.go(AppPaths.home);
      } else {
        setState(() => _error = 'Failed to create lesson');
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
                        'create.create_lesson'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
                            onTap: _loading ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'common.save'.tr(),
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
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Lesson title',
                          labelStyle: TextStyle(color: Colors.white70),
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'create.sections'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._sections.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ContentCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Section ${i + 1}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'create.title'.tr(),
                                    labelStyle: TextStyle(color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                  onChanged: (v) => s['title'] = v,
                                  enabled: !_loading,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'create.body'.tr(),
                                    labelStyle: TextStyle(color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                  maxLines: 3,
                                  onChanged: (v) => s['body'] = v,
                                  enabled: !_loading,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Key takeaway (optional)',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                  onChanged: (v) => s['key_takeaway'] = v,
                                  enabled: !_loading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      'Quiz (optional)',
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
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'create.question'.tr(),
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            onChanged: (v) => _quizQuestion = v,
                            enabled: !_loading,
                          ),
                          const SizedBox(height: 16),
                          ..._quizOptionControllers.asMap().entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: e.key,
                                    groupValue: _correctIndex,
                                    fillColor: MaterialStateProperty.resolveWith<Color>(
                                      (states) => states.contains(MaterialState.selected)
                                          ? AppColors.primary
                                          : Colors.white70,
                                    ),
                                    onChanged: _loading ? null : (v) => setState(() => _correctIndex = v ?? 0),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: e.value,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Option ${e.key + 1}',
                                        labelStyle: TextStyle(color: Colors.white70),
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
                                  ),
                                ],
                              ),
                            );
                          }),
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
