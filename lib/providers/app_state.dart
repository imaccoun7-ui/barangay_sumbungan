import 'package:flutter/foundation.dart';

import '../models/announcement_model.dart';
import '../models/directory_model.dart';
import '../models/document_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/announcement_service.dart';
import '../services/auth_service.dart';
import '../services/backend/barangay_backend.dart';
import '../services/backend/local_backend.dart';
import '../services/directory_service.dart';
import '../services/document_service.dart';
import '../services/notification_service.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';

/// Single source of truth for the UI. Screens listen to this notifier and call
/// the use-case methods below; they never talk to the backend directly.
class AppState extends ChangeNotifier {
  AppState({BarangayBackend? backend, StorageService? storage})
      : backend = backend ?? LocalBackend(),
        storage = storage ?? StorageService() {
    auth = AuthService(this.backend);
    reports = ReportService(this.backend);
    documents = DocumentService(this.backend);
    announcements = AnnouncementService(this.backend);
    notifications = NotificationService(this.backend);
    directory = DirectoryService(this.backend);
  }

  final BarangayBackend backend;
  final StorageService storage;

  late final AuthService auth;
  late final ReportService reports;
  late final DocumentService documents;
  late final AnnouncementService announcements;
  late final NotificationService notifications;
  late final DirectoryService directory;

  bool _initialising = true;
  bool _busy = false;

  List<ReportModel> _reports = <ReportModel>[];
  List<DocumentRequestModel> _documentRequests = <DocumentRequestModel>[];
  List<AnnouncementModel> _announcementList = <AnnouncementModel>[];
  List<NotificationModel> _notificationList = <NotificationModel>[];
  List<DirectoryEntryModel> _directoryList = <DirectoryEntryModel>[];
  List<EmergencyContactModel> _emergencyList = <EmergencyContactModel>[];
  List<BarangayLocationModel> _locationList = <BarangayLocationModel>[];
  List<UserModel> _residentList = <UserModel>[];
  List<NotificationModel> _notificationLog = <NotificationModel>[];

  bool get initialising => _initialising;
  bool get busy => _busy;
  UserModel? get user => auth.currentUser;
  bool get isAdmin => user?.isAdmin ?? false;

  List<ReportModel> get reportList => List<ReportModel>.unmodifiable(_reports);
  List<DocumentRequestModel> get documentRequestList =>
      List<DocumentRequestModel>.unmodifiable(_documentRequests);
  List<AnnouncementModel> get announcementList =>
      List<AnnouncementModel>.unmodifiable(_announcementList);
  List<NotificationModel> get notificationList =>
      List<NotificationModel>.unmodifiable(_notificationList);
  List<DirectoryEntryModel> get directoryList =>
      List<DirectoryEntryModel>.unmodifiable(_directoryList);
  List<EmergencyContactModel> get emergencyContacts =>
      List<EmergencyContactModel>.unmodifiable(_emergencyList);
  List<BarangayLocationModel> get locations =>
      List<BarangayLocationModel>.unmodifiable(_locationList);
  List<UserModel> get residents => List<UserModel>.unmodifiable(_residentList);
  List<NotificationModel> get notificationLog =>
      List<NotificationModel>.unmodifiable(_notificationLog);

  int get unreadNotificationCount =>
      _notificationList.where((NotificationModel n) => !n.isRead).length;

  List<AnnouncementModel> get publishedAnnouncements =>
      _announcementList.where((AnnouncementModel a) => a.published).toList();

  ReportModel? reportById(String id) {
    for (final ReportModel report in _reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  DocumentRequestModel? documentRequestById(String id) {
    for (final DocumentRequestModel request in _documentRequests) {
      if (request.id == id) return request;
    }
    return null;
  }

  AnnouncementModel? announcementById(String id) {
    for (final AnnouncementModel item in _announcementList) {
      if (item.id == id) return item;
    }
    return null;
  }

  int get pendingReports => _reports
      .where((ReportModel r) => r.status == ReportStatus.pending)
      .length;
  int get inProgressReports => _reports
      .where((ReportModel r) => r.status == ReportStatus.inProgress)
      .length;
  int get solvedReports =>
      _reports.where((ReportModel r) => r.status == ReportStatus.solved).length;
  int get pendingDocumentRequests => _documentRequests
      .where((DocumentRequestModel d) => d.status == DocumentStatus.pending)
      .length;

  /// Restores a saved session and pre-loads the data the user may see.
  Future<void> bootstrap() async {
    await backend.init();
    await storage.enableCloud();
    await auth.restoreSession();
    await _loadAll();
    _initialising = false;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    await auth.signIn(email: email, password: password);
    await _loadAll();
    notifyListeners();
  }

  Future<void> registerResident({
    required String fullName,
    required String email,
    required String password,
    required String contactNumber,
    required String address,
    String householdInfo = '',
  }) async {
    await auth.registerResident(
      fullName: fullName,
      email: email,
      password: password,
      contactNumber: contactNumber,
      address: address,
      householdInfo: householdInfo,
    );
    await _loadAll();
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    _reports = <ReportModel>[];
    _documentRequests = <DocumentRequestModel>[];
    _notificationList = <NotificationModel>[];
    _residentList = <UserModel>[];
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadAll();
    notifyListeners();
  }

  Future<void> _loadAll() async {
    _announcementList = await announcements.fetch(
      publishedOnly: !isAdmin,
    );
    _directoryList = await directory.fetchDirectory();
    _emergencyList = await directory.fetchEmergencyContacts();
    _locationList = await directory.fetchLocations();
    if (user == null) {
      _reports = <ReportModel>[];
      _documentRequests = <DocumentRequestModel>[];
      _notificationList = <NotificationModel>[];
      _residentList = <UserModel>[];
      return;
    }
    _reports = await reports.fetchReports(forUser: isAdmin ? null : user);
    _documentRequests =
        await documents.fetchRequests(forUser: isAdmin ? null : user);
    _notificationList = await notifications.fetch(user!.id);
    // Only administrators may read the full resident list.
    _residentList = isAdmin ? await backend.listUsers() : <UserModel>[];
    if (isAdmin) {
      final List<NotificationModel> log = <NotificationModel>[];
      for (final UserModel resident in _residentList) {
        log.addAll(await notifications.fetch(resident.id));
      }
      log.sort((NotificationModel a, NotificationModel b) =>
          b.createdAt.compareTo(a.createdAt));
      _notificationLog = log;
    } else {
      _notificationLog = <NotificationModel>[];
    }
  }

  // ------------------------------------------------------------- resident use

  Future<ReportModel> submitReport({
    required String title,
    required String category,
    required String description,
    required String location,
    List<String> imageUrls = const <String>[],
  }) async {
    final UserModel? resident = user;
    if (resident == null) throw BackendException('You are not signed in.');
    final ReportModel report = await reports.submitReport(
      resident: resident,
      title: title,
      category: category,
      description: description,
      location: location,
      imageUrls: imageUrls,
    );
    _reports = <ReportModel>[report, ..._reports];
    notifyListeners();
    return report;
  }

  Future<DocumentRequestModel> submitDocumentRequest({
    required String documentType,
    required String fullName,
    required String address,
    required String purpose,
    required String contactNumber,
    String additionalInformation = '',
  }) async {
    final UserModel? resident = user;
    if (resident == null) throw BackendException('You are not signed in.');
    final DocumentRequestModel request = await documents.submitRequest(
      resident: resident,
      documentType: documentType,
      fullName: fullName,
      address: address,
      purpose: purpose,
      contactNumber: contactNumber,
      additionalInformation: additionalInformation,
    );
    _documentRequests = <DocumentRequestModel>[request, ..._documentRequests];
    notifyListeners();
    return request;
  }

  Future<void> markNotificationRead(NotificationModel notification,
      {bool isRead = true}) async {
    await notifications.markRead(notification.id, isRead: isRead);
    _notificationList = _notificationList
        .map((NotificationModel n) =>
            n.id == notification.id ? n.copyWith(isRead: isRead) : n)
        .toList();
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    final UserModel? current = user;
    if (current == null) return;
    await notifications.markAllRead(current.id);
    _notificationList = _notificationList
        .map((NotificationModel n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  Future<void> updateOwnProfile({
    required String fullName,
    required String contactNumber,
    required String address,
    required String householdInfo,
  }) async {
    final UserModel? current = user;
    if (current == null) throw BackendException('You are not signed in.');
    final UserModel updated = current.copyWith(
      fullName: fullName,
      contactNumber: contactNumber,
      address: address,
      householdInfo: householdInfo,
    );
    await auth.updateProfile(updated);
    _residentList = _residentList
        .map((UserModel u) => u.id == updated.id ? updated : u)
        .toList();
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      auth.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  Future<void> requestPasswordReset(String email) =>
      auth.sendPasswordReset(email);

  // ---------------------------------------------------------------- admin use

  void _ensureAdmin() {
    if (!isAdmin) {
      throw BackendException(
          'Administrator access is required for this action.');
    }
  }

  Future<void> updateReportStatus({
    required ReportModel report,
    required ReportStatus status,
    required String adminResponse,
  }) async {
    _ensureAdmin();
    final ReportModel updated = await reports.updateStatus(
      report: report,
      status: status,
      adminResponse: adminResponse,
    );
    _reports = _reports
        .map((ReportModel r) => r.id == updated.id ? updated : r)
        .toList();
    final UserModel? resident = _residentList.cast<UserModel?>().firstWhere(
        (UserModel? u) => u?.id == updated.userId,
        orElse: () => null);
    if (resident != null) {
      await notifications.createForUsers(
        recipients: <UserModel>[resident],
        title:
            'Report ${updated.referenceNumber} is now ${updated.status.label}',
        message: adminResponse.trim().isEmpty
            ? 'The barangay updated the status of your report "${updated.title}".'
            : adminResponse.trim(),
        type: NotificationType.reportUpdate,
        relatedRecordId: updated.id,
      );
      _notificationList = await notifications.fetch(user!.id);
    }
    notifyListeners();
  }

  Future<void> updateDocumentStatus({
    required DocumentRequestModel request,
    required DocumentStatus status,
    required String adminResponse,
  }) async {
    _ensureAdmin();
    final DocumentRequestModel updated = await documents.updateStatus(
      request: request,
      status: status,
      adminResponse: adminResponse,
    );
    _documentRequests = _documentRequests
        .map((DocumentRequestModel d) => d.id == updated.id ? updated : d)
        .toList();
    final UserModel? resident = _residentList.cast<UserModel?>().firstWhere(
        (UserModel? u) => u?.id == updated.userId,
        orElse: () => null);
    if (resident != null) {
      await notifications.createForUsers(
        recipients: <UserModel>[resident],
        title: '${updated.documentType} — ${updated.status.label}',
        message: adminResponse.trim().isEmpty
            ? 'Your document request ${updated.referenceNumber} was updated.'
            : adminResponse.trim(),
        type: NotificationType.documentUpdate,
        relatedRecordId: updated.id,
      );
      _notificationList = await notifications.fetch(user!.id);
    }
    notifyListeners();
  }

  Future<AnnouncementModel> saveAnnouncement({
    AnnouncementModel? existing,
    required String title,
    required String content,
    required String category,
    String imageUrl = '',
    bool published = true,
  }) async {
    _ensureAdmin();
    final AnnouncementModel saved = await announcements.publish(
      author: user!,
      existing: existing,
      title: title,
      content: content,
      category: category,
      imageUrl: imageUrl,
      published: published,
    );
    final bool exists =
        _announcementList.any((AnnouncementModel a) => a.id == saved.id);
    _announcementList = exists
        ? _announcementList
            .map((AnnouncementModel a) => a.id == saved.id ? saved : a)
            .toList()
        : <AnnouncementModel>[saved, ..._announcementList];
    if (published && !exists) {
      final List<UserModel> recipients =
          _residentList.where((UserModel u) => u.isActive).toList();
      await notifications.createForUsers(
        recipients: recipients,
        title: 'New ${saved.category}: ${saved.title}',
        message: saved.content.length > 120
            ? '${saved.content.substring(0, 120)}…'
            : saved.content,
        type: NotificationType.announcement,
        relatedRecordId: saved.id,
      );
      _notificationList = await notifications.fetch(user!.id);
    }
    notifyListeners();
    return saved;
  }

  Future<void> toggleAnnouncementPublished(
      AnnouncementModel announcement) async {
    _ensureAdmin();
    final AnnouncementModel saved = await announcements.publish(
      author: user!,
      existing: announcement,
      title: announcement.title,
      content: announcement.content,
      category: announcement.category,
      imageUrl: announcement.imageUrl,
      published: !announcement.published,
    );
    _announcementList = _announcementList
        .map((AnnouncementModel a) => a.id == saved.id ? saved : a)
        .toList();
    notifyListeners();
  }

  Future<void> deleteAnnouncement(AnnouncementModel announcement) async {
    _ensureAdmin();
    await announcements.delete(announcement.id);
    _announcementList = _announcementList
        .where((AnnouncementModel a) => a.id != announcement.id)
        .toList();
    notifyListeners();
  }

  Future<void> saveDirectoryEntry(DirectoryEntryModel entry) async {
    _ensureAdmin();
    final DirectoryEntryModel saved = await directory.saveEntry(entry);
    final bool exists =
        _directoryList.any((DirectoryEntryModel e) => e.id == saved.id);
    _directoryList = exists
        ? _directoryList
            .map((DirectoryEntryModel e) => e.id == saved.id ? saved : e)
            .toList()
        : <DirectoryEntryModel>[..._directoryList, saved];
    notifyListeners();
  }

  Future<void> deleteDirectoryEntry(DirectoryEntryModel entry) async {
    _ensureAdmin();
    await directory.deleteEntry(entry.id);
    _directoryList = _directoryList
        .where((DirectoryEntryModel e) => e.id != entry.id)
        .toList();
    notifyListeners();
  }

  Future<void> saveEmergencyContact(EmergencyContactModel contact) async {
    _ensureAdmin();
    final EmergencyContactModel saved =
        await directory.saveEmergencyContact(contact);
    final bool exists =
        _emergencyList.any((EmergencyContactModel c) => c.id == saved.id);
    _emergencyList = exists
        ? _emergencyList
            .map((EmergencyContactModel c) => c.id == saved.id ? saved : c)
            .toList()
        : <EmergencyContactModel>[..._emergencyList, saved];
    notifyListeners();
  }

  Future<void> deleteEmergencyContact(EmergencyContactModel contact) async {
    _ensureAdmin();
    await directory.deleteEmergencyContact(contact.id);
    _emergencyList = _emergencyList
        .where((EmergencyContactModel c) => c.id != contact.id)
        .toList();
    notifyListeners();
  }

  Future<void> saveLocation(BarangayLocationModel location) async {
    _ensureAdmin();
    final BarangayLocationModel saved = await directory.saveLocation(location);
    final bool exists =
        _locationList.any((BarangayLocationModel l) => l.id == saved.id);
    _locationList = exists
        ? _locationList
            .map((BarangayLocationModel l) => l.id == saved.id ? saved : l)
            .toList()
        : <BarangayLocationModel>[..._locationList, saved];
    notifyListeners();
  }

  Future<void> deleteLocation(BarangayLocationModel location) async {
    _ensureAdmin();
    await directory.deleteLocation(location.id);
    _locationList = _locationList
        .where((BarangayLocationModel l) => l.id != location.id)
        .toList();
    notifyListeners();
  }

  Future<void> setResidentStatus(
      UserModel resident, AccountStatus status) async {
    _ensureAdmin();
    if (resident.isAdmin) {
      throw BackendException(
          'Administrator accounts cannot be suspended here.');
    }
    await backend.setAccountStatus(resident.id, status);
    _residentList = _residentList
        .map((UserModel u) =>
            u.id == resident.id ? u.copyWith(accountStatus: status) : u)
        .toList();
    notifyListeners();
  }

  Future<void> sendNotificationToResidents({
    required List<UserModel> recipients,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
  }) async {
    _ensureAdmin();
    await notifications.createForUsers(
      recipients: recipients,
      title: title,
      message: message,
      type: type,
    );
    _notificationList = await notifications.fetch(user!.id);
    notifyListeners();
  }

  Future<void> setBusy(bool value) async {
    _busy = value;
    notifyListeners();
  }
}
