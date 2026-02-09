class LessonSection {
  const LessonSection({
    required this.id,
    required this.lessonId,
    required this.sortOrder,
    this.title,
    this.body,
    this.imageUrl,
    this.keyTakeaway,
  });

  final String id;
  final String lessonId;
  final int sortOrder;
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? keyTakeaway;

  factory LessonSection.fromJson(Map<String, dynamic> json) {
    return LessonSection(
      id: json['id'] as String? ?? '',
      lessonId: json['lesson_id'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      title: json['title'] as String?,
      body: json['body'] as String?,
      imageUrl: json['image_url'] as String?,
      keyTakeaway: json['key_takeaway'] as String?,
    );
  }
}
