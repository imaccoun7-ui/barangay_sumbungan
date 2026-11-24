enum NotificationType {
  general,
  emergency,
  reportUpdate,
  documentUpdate,
  announcement;

  String get label {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.reportUpdate:
        return 'Report update';
      case NotificationType.documentUpdate:
        return 'Document request';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  static NotificationType fromName(String? value) {
    return NotificationType.values.firstWhere(
      (NotificationType t) => t.name == value,
      orElse: () => NotificationType.general,
    );
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.message,
    this.type = NotificationType.general,
    this.relatedRecordId = '',
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final String recipientUserId;
  final String title;
  final String message;
  final NotificationType type;
  final String relatedRecordId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      recipientUserId: recipientUserId,
      title: title,
      message: message,
      type: type,
      relatedRecordId: relatedRecordId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'notificationId': id,
        'recipientUserId': recipientUserId,
        'title': title,
        'message': message,
        'type': type.name,
        'relatedRecordId': relatedRecordId,
        'isRead': isRead,
        'createdAt': createdAt,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: (map['notificationId'] ?? map['id'] ?? '').toString(),
      recipientUserId: (map['recipientUserId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: NotificationType.fromName(map['type'] as String?),
      relatedRecordId: (map['relatedRecordId'] ?? '').toString(),
      isRead: map['isRead'] == true,
      createdAt: _date(map['createdAt']),
    );
  }
}

DateTime _date(Object? value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
