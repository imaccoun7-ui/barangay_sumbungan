import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'backend/barangay_backend.dart';

/// Notification history plus the delivery hook for Firebase Cloud Messaging.
///
/// `createForUsers` writes the in-app record; when FCM credentials are added,
/// the same method should also send the push through
/// a push service / Cloud Function.
class NotificationService {
  NotificationService(this._backend);

  final BarangayBackend _backend;

  Future<List<NotificationModel>> fetch(String userId) =>
      _backend.listNotifications(userId);

  Future<void> createForUsers({
    required List<UserModel> recipients,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    String relatedRecordId = '',
  }) async {
    if (recipients.isEmpty) return;
    final DateTime now = DateTime.now();
    final List<NotificationModel> notifications = <NotificationModel>[];
    for (final UserModel user in recipients) {
      notifications.add(
        NotificationModel(
          id: 'n_${user.id}_${now.microsecondsSinceEpoch}_${notifications.length}',
          recipientUserId: user.id,
          title: title,
          message: message,
          type: type,
          relatedRecordId: relatedRecordId,
          createdAt: now,
        ),
      );
    }
    await _backend.addNotifications(notifications);
  }

  Future<void> markRead(String id, {bool isRead = true}) =>
      _backend.markNotificationRead(id, isRead: isRead);

  Future<void> markAllRead(String userId) =>
      _backend.markAllNotificationsRead(userId);
}
