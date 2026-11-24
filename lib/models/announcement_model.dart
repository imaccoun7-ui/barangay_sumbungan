class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl = '',
    this.category = 'Announcements',
    this.published = true,
    this.createdBy = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String category;
  final bool published;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnnouncementModel copyWith({
    String? title,
    String? content,
    String? imageUrl,
    String? category,
    bool? published,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      published: published ?? this.published,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'announcementId': id,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'category': category,
        'published': published,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: (map['announcementId'] ?? map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      category: (map['category'] ?? 'Announcements').toString(),
      published: map['published'] != false,
      createdBy: (map['createdBy'] ?? '').toString(),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }
}

DateTime _date(Object? value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
