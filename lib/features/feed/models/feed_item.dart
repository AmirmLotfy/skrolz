/// Unified feed item: post or lesson (minimal fields for pager).
class FeedItem {
  const FeedItem({
    required this.id,
    required this.contentType,
    this.title,
    this.body,
    this.authorId,
    this.categoryId,
    this.createdAt,
    this.whyShown,
    this.difficulty,
    this.timeToReadSec,
  });

  final String id;
  final String contentType; // 'post' | 'lesson'
  final String? title;
  final String? body;
  final String? authorId;
  final String? categoryId;
  final DateTime? createdAt;
  final String? whyShown;
  final String? difficulty;
  final int? timeToReadSec;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String? ?? '',
      contentType: json['content_type'] as String? ?? 'post',
      title: json['title'] as String?,
      body: json['body'] as String?,
      authorId: json['author_id'] as String?,
      categoryId: json['category_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      whyShown: json['why_shown'] as String?,
      difficulty: json['difficulty'] as String?,
      timeToReadSec: json['time_to_read_sec'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_type': contentType,
      'title': title,
      'body': body,
      'author_id': authorId,
      'category_id': categoryId,
      'created_at': createdAt?.toIso8601String(),
      'why_shown': whyShown,
      'difficulty': difficulty,
      'time_to_read_sec': timeToReadSec,
    };
  }
}
