import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/features/lesson/models/lesson.dart';
import 'package:skrolz_app/features/lesson/models/lesson_section.dart';
import 'package:skrolz_app/services/error_logger.dart';

/// Fetch lesson by ID with sections and quiz_questions. Persist quiz attempts.
class LessonRepository {
  static Future<Lesson?> getLessonById(String id) async {
    if (!AppSupabase.isInitialized) return null;
    try {
      final lessonRes = await AppSupabase.client
          .from('lessons')
          .select('id, author_id, category_id, title, thumbnail_url')
          .eq('id', id)
          .maybeSingle();
      if (lessonRes == null) return null;
      final lessonMap = Map<String, dynamic>.from(lessonRes as Map);

      final sectionsRes = await AppSupabase.client
          .from('lesson_sections')
          .select('id, lesson_id, sort_order, title, body, image_url, key_takeaway')
          .eq('lesson_id', id)
          .order('sort_order', ascending: true);
      final sectionsList = (sectionsRes as List)
          .map((e) => LessonSection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final quizRes = await AppSupabase.client
          .from('lesson_quiz_questions')
          .select('question, options, correct_index, sort_order')
          .eq('lesson_id', id)
          .order('sort_order', ascending: true);
      final quizList = (quizRes as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        final opts = m['options'];
        return {
          'question': m['question'],
          'options': opts is List ? opts : (opts != null ? [opts.toString()] : []),
          'correct_index': m['correct_index'] ?? 0,
        };
      }).toList();

      return Lesson.fromJson({
        ...lessonMap,
        'sections': sectionsList.map((s) => {
              'id': s.id,
              'lesson_id': s.lessonId,
              'sort_order': s.sortOrder,
              'title': s.title,
              'body': s.body,
              'image_url': s.imageUrl,
              'key_takeaway': s.keyTakeaway,
            }).toList(),
        'quiz_questions': quizList,
      });
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'LessonRepository.getLessonById', context: {'lessonId': id});
      return null;
    }
  }

  /// Create lesson with sections and optional quiz. Calls moderate-content on text; sets moderation_status.
  static Future<String?> createLesson({
    required String title,
    List<Map<String, dynamic>> sections = const [],
    List<Map<String, dynamic>> quizQuestions = const [],
  }) async {
    if (!AppSupabase.isInitialized) return null;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final lessonRes = await AppSupabase.client.from('lessons').insert({
        'author_id': uid,
        'title': title,
        'moderation_status': 'pending',
      }).select('id').single();
      final lessonId = lessonRes['id'] as String?;
      if (lessonId == null) return null;

      for (var i = 0; i < sections.length; i++) {
        await AppSupabase.client.from('lesson_sections').insert({
          'lesson_id': lessonId,
          'sort_order': i,
          'title': sections[i]['title'],
          'body': sections[i]['body'],
          'image_url': sections[i]['image_url'],
          'key_takeaway': sections[i]['key_takeaway'],
        });
      }
      for (var i = 0; i < quizQuestions.length; i++) {
        final q = quizQuestions[i];
        await AppSupabase.client.from('lesson_quiz_questions').insert({
          'lesson_id': lessonId,
          'sort_order': i,
          'question': q['question'],
          'options': q['options'] is List ? q['options'] : [q['question']],
          'correct_index': q['correct_index'] ?? 0,
        });
      }

      String status = 'approved';
      try {
        final modRes = await AppSupabase.client.functions.invoke(
          'moderate-content',
          body: {'content_type': 'lesson', 'content_id': lessonId, 'text': title},
        );
        final st = (modRes.data as Map?)?['status'] as String?;
        if (st != null && st != 'approved') status = st;
      } catch (_) {}
      for (final s in sections) {
        final body = s['body'] as String? ?? '';
        if (body.isEmpty) continue;
        try {
          final modRes = await AppSupabase.client.functions.invoke(
            'moderate-content',
            body: {'content_type': 'lesson', 'content_id': lessonId, 'text': body},
          );
          final st = (modRes.data as Map?)?['status'] as String?;
          if (st != null && st != 'approved') status = st;
        } catch (_) {}
      }
      await AppSupabase.client.from('lessons').update({'moderation_status': status}).eq('id', lessonId);
      return lessonId;
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'LessonRepository.createLesson', context: {
        'title': title,
        'sectionsCount': sections.length,
        'quizQuestionsCount': quizQuestions.length,
      });
      return null;
    }
  }

  /// Persist quiz attempt for analytics/streaks. Upserts by (lesson_id, user_id).
  static Future<void> saveQuizAttempt(String lessonId, Map<String, dynamic> answersJson, {int? score}) async {
    if (!AppSupabase.isInitialized) return;
    final uid = AppSupabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await AppSupabase.client.from('lesson_attempts').upsert({
        'lesson_id': lessonId,
        'user_id': uid,
        'answers_json': answersJson,
        'score': score,
      }, onConflict: 'lesson_id,user_id');
    } catch (e, st) {
      ErrorLogger.logError(e, st, tag: 'LessonRepository.saveQuizAttempt', context: {
        'lessonId': lessonId,
        'score': score,
      });
    }
  }
}
