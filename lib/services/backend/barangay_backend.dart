import '../../models/announcement_model.dart';
import '../../models/directory_model.dart';
import '../../models/document_model.dart';
import '../../models/notification_model.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';

/// Raised by the backend when an operation cannot be completed.
class BackendException implements Exception {
  BackendException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Data contract used by the service layer.
///
/// `LocalBackend` implements this today with clearly-labelled sample records
/// and on-device persistence. Swapping in a remote database only requires a
/// second implementation of this interface; no screen or service has to change.
abstract class BarangayBackend {
  Future<void> init();

  // Accounts
  Future<UserModel?> authenticate(String email, String password);
  Future<UserModel> createResident({
    required String fullName,
    required String email,
    required String password,
    required String contactNumber,
    required String address,
    String householdInfo,
  });
  Future<void> updateProfile(UserModel user);
  Future<void> setAccountStatus(String userId, AccountStatus status);
  Future<void> changePassword(
      String userId, String currentPassword, String newPassword);
  Future<void> requestPasswordReset(String email);
  Future<UserModel?> findUserById(String userId);
  Future<List<UserModel>> listUsers();

  // Reports
  Future<List<ReportModel>> listReports({String? userId});
  Future<ReportModel> createReport(ReportModel report);
  Future<ReportModel> updateReport(ReportModel report);

  // Document requests
  Future<List<DocumentRequestModel>> listDocumentRequests({String? userId});
  Future<DocumentRequestModel> createDocumentRequest(
      DocumentRequestModel request);
  Future<DocumentRequestModel> updateDocumentRequest(
      DocumentRequestModel request);

  // Announcements
  Future<List<AnnouncementModel>> listAnnouncements(
      {bool publishedOnly = true});
  Future<AnnouncementModel> saveAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String id);

  // Notifications
  Future<List<NotificationModel>> listNotifications(String userId);
  Future<void> addNotification(NotificationModel notification);
  Future<void> addNotifications(List<NotificationModel> notifications);
  Future<void> markNotificationRead(String notificationId,
      {required bool isRead});
  Future<void> markAllNotificationsRead(String userId);

  // Directory & emergency contacts & map locations
  Future<List<DirectoryEntryModel>> listDirectory();
  Future<DirectoryEntryModel> saveDirectoryEntry(DirectoryEntryModel entry);
  Future<void> deleteDirectoryEntry(String id);
  Future<List<EmergencyContactModel>> listEmergencyContacts();
  Future<EmergencyContactModel> saveEmergencyContact(
      EmergencyContactModel contact);
  Future<void> deleteEmergencyContact(String id);
  Future<List<BarangayLocationModel>> listLocations();
  Future<BarangayLocationModel> saveLocation(BarangayLocationModel location);
  Future<void> deleteLocation(String id);
}
