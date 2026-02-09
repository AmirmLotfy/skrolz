import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/lesson_repository.dart';
import 'package:skrolz_app/features/lesson/models/lesson.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Multi-slide lesson viewer: glassmorphism controls overlay, modern quiz UI.
class LessonViewerScreen extends StatefulWidget {
  const LessonViewerScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, int> _quizAnswers = {};
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _totalPages {
    int n = widget.lesson.sections.length;
    if (widget.lesson.sections.any((s) => s.keyTakeaway != null && s.keyTakeaway!.isNotEmpty)) n += 1;
    if (widget.lesson.quizQuestions.isNotEmpty) n += 1;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = widget.lesson.sections;
    final takeaway = sections.isNotEmpty ? sections.last.keyTakeaway : null;
    final hasTakeaway = takeaway != null && takeaway.isNotEmpty;
    final quiz = widget.lesson.quizQuestions.take(3).toList();

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              for (final section in sections)
                _SectionSlide(
                  title: section.title,
                  body: section.body,
                  imageUrl: section.imageUrl,
                ),
              if (hasTakeaway)
                _TakeawaySlide(takeaway: takeaway!),
              if (quiz.isNotEmpty)
                _QuizSlide(
                  questions: quiz,
                  answers: _quizAnswers,
                  submitted: _quizSubmitted,
                  onAnswer: (index, value) {
                    setState(() => _quizAnswers[index] = value);
                  },
                  onSubmit: () {
                    HapticFeedback.mediumImpact();
                    final quiz = widget.lesson.quizQuestions.take(3).toList();
                    int score = 0;
                    for (var i = 0; i < quiz.length; i++) {
                      if (_quizAnswers[i] == quiz[i].correctIndex) score++;
                    }
                    final answersJson = _quizAnswers.map((k, v) => MapEntry(k.toString(), v));
                    LessonRepository.saveQuizAttempt(widget.lesson.id, answersJson, score: score);
                    setState(() => _quizSubmitted = true);
                  },
                ),
            ],
          ),
          // Glassmorphism header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassSurface(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                blur: 25,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Glassmorphism bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassSurface(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  blur: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      const SizedBox(width: 24),
                      if (_currentPage < _totalPages - 1)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSlide extends StatelessWidget {
  const _SectionSlide({this.title, this.body, this.imageUrl});

  final String? title;
  final String? body;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.image, size: 64, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (body != null && body!.isNotEmpty)
            Text(
              body!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _TakeawaySlide extends StatelessWidget {
  const _TakeawaySlide({required this.takeaway});

  final String takeaway;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ContentCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lightbulb, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'Key Takeaway',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                takeaway,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizSlide extends StatelessWidget {
  const _QuizSlide({
    required this.questions,
    required this.answers,
    required this.submitted,
    required this.onAnswer,
    required this.onSubmit,
  });

  final List<QuizQuestion> questions;
  final Map<int, int> answers;
  final bool submitted;
  final void Function(int index, int value) onAnswer;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          ContentCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.quiz, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick Quiz',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...questions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final selected = answers[i];
            return ContentCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...q.options.asMap().entries.map((opt) {
                    final isCorrect = opt.key == q.correctIndex;
                    final isSelected = selected == opt.key;
                    final showResult = submitted && isSelected;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: submitted
                            ? null
                            : () => onAnswer(i, opt.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showResult
                                ? (isCorrect
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.danger.withValues(alpha: 0.2))
                                : (isSelected
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : Colors.transparent),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDarkSecondary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textDarkSecondary.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt.value,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: showResult
                                        ? (isCorrect ? AppColors.success : AppColors.danger)
                                        : null,
                                  ),
                                ),
                              ),
                              if (showResult)
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? AppColors.success : AppColors.danger,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          if (!submitted)
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
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            ContentCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz Complete!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
