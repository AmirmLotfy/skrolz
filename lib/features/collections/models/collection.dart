class Collection {
  const Collection({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.coverUrl,
    this.isPublic = true,
    this.itemIds = const [],
    this.itemTypes = const [],
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final List<String> itemIds;
  final List<String> itemTypes;

  factory Collection.fromJson(Map<String, dynamic> json) {
    final ids = json['item_ids'] as List<dynamic>? ?? [];
    final types = json['item_types'] as List<dynamic>? ?? [];
    return Collection(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      itemIds: ids.map((e) => e.toString()).toList(),
      itemTypes: types.map((e) => e.toString()).toList(),
    );
  }
}
