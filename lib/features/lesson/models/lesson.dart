import 'package:skrolz_app/features/lesson/models/lesson_section.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.authorId,
    this.categoryId,
    required this.title,
    this.thumbnailUrl,
    this.sections = const [],
    this.quizQuestions = const [],
  });

  final String id;
  final String authorId;
  final String? categoryId;
  final String title;
  final String? thumbnailUrl;
  final List<LessonSection> sections;
  final List<QuizQuestion> quizQuestions;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List<dynamic>?;
    final sections = sectionsList != null
        ? sectionsList.map((e) => LessonSection.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : <LessonSection>[];
    final quizList = json['quiz_questions'] as List<dynamic>?;
    final quiz = quizList != null
        ? quizList.map((e) => QuizQuestion.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : <QuizQuestion>[];
    return Lesson(
      id: json['id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      sections: sections,
      quizQuestions: quiz,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final opts = json['options'] as List<dynamic>? ?? [];
    return QuizQuestion(
      question: json['question'] as String? ?? '',
      options: opts.map((e) => e.toString()).toList(),
      correctIndex: json['correct_index'] as int? ?? 0,
    );
  }
}
