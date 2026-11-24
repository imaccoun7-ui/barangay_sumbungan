import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/announcement_model.dart';
import '../../models/directory_model.dart';
import '../../models/document_model.dart';
import '../../models/notification_model.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import 'barangay_backend.dart';

/// On-device implementation of [BarangayBackend].
///
/// It keeps the same document shapes that Firestore will use and persists them
/// as JSON through `shared_preferences`, so the app is fully usable before
/// Firebase credentials exist. Every record created here is real application
/// state — only the seeded directory/hotline entries are marked as samples.
class LocalBackend implements BarangayBackend {
  LocalBackend({this.storageKey = 'barangay_sumbungan_db_v1'});

  final String storageKey;

  final Map<String, UserModel> _users = <String, UserModel>{};
  final Map<String, String> _passwords = <String, String>{};
  final Map<String, ReportModel> _reports = <String, ReportModel>{};
  final Map<String, DocumentRequestModel> _documents =
      <String, DocumentRequestModel>{};
  final Map<String, AnnouncementModel> _announcements =
      <String, AnnouncementModel>{};
  final Map<String, NotificationModel> _notifications =
      <String, NotificationModel>{};
  final Map<String, DirectoryEntryModel> _directory =
      <String, DirectoryEntryModel>{};
  final Map<String, EmergencyContactModel> _emergency =
      <String, EmergencyContactModel>{};
  final Map<String, BarangayLocationModel> _locations =
      <String, BarangayLocationModel>{};

  SharedPreferences? _prefs;
  int _reportSequence = 89;
  int _documentSequence = 12;

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null; // Storage unavailable (e.g. tests) — stay in memory.
    }
    final String? raw = _prefs?.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _seed();
      await _persist();
      return;
    }
    try {
      _decode(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _seed();
    }
  }

  // ---------------------------------------------------------------- accounts

  @override
  Future<UserModel?> authenticate(String email, String password) async {
    final String normalised = email.trim().toLowerCase();
    final UserModel? user = _users.values
        .where((UserModel u) => u.email.toLowerCase() == normalised)
        .cast<UserModel?>()
        .firstWhere((UserModel? u) => u != null, orElse: () => null);
    if (user == null) return null;
    if (_passwords[user.id] != password) return null;
    if (!user.isActive) {
      throw BackendException(
        'This account has been suspended. Please contact the barangay office.',
      );
    }
    return user;
  }

  @override
  Future<UserModel> createResident({
    required String fullName,
    required String email,
    required String password,
    required String contactNumber,
    required String address,
    String householdInfo = '',
  }) async {
    final String normalised = email.trim().toLowerCase();
    if (_users.values
        .any((UserModel u) => u.email.toLowerCase() == normalised)) {
      throw BackendException('An account with this email already exists.');
    }
    final UserModel user = UserModel(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: normalised,
      contactNumber: contactNumber.trim(),
      address: address.trim(),
      householdInfo: householdInfo.trim(),
      role: UserRole.resident,
      createdAt: DateTime.now(),
    );
    _users[user.id] = user;
    _passwords[user.id] = password;
    await _persist();
    return user;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    _users[user.id] = user;
    await _persist();
  }

  @override
  Future<void> setAccountStatus(String userId, AccountStatus status) async {
    final UserModel? user = _users[userId];
    if (user == null) throw BackendException('Resident account not found.');
    _users[userId] = user.copyWith(accountStatus: status);
    await _persist();
  }

  @override
  Future<void> changePassword(
      String userId, String currentPassword, String newPassword) async {
    if (_passwords[userId] != currentPassword) {
      throw BackendException('The current password is incorrect.');
    }
    _passwords[userId] = newPassword;
    await _persist();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final String normalised = email.trim().toLowerCase();
    if (!_users.values
        .any((UserModel u) => u.email.toLowerCase() == normalised)) {
      throw BackendException('No account is registered with this email.');
    }
    // A real deployment calls FirebaseAuth.sendPasswordResetEmail here.
  }

  @override
  Future<UserModel?> findUserById(String userId) async => _users[userId];

  @override
  Future<List<UserModel>> listUsers() async {
    final List<UserModel> users = _users.values.toList()
      ..sort((UserModel a, UserModel b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  // ----------------------------------------------------------------- reports

  @override
  Future<List<ReportModel>> listReports({String? userId}) async {
    final List<ReportModel> reports = _reports.values
        .where((ReportModel r) => userId == null || r.userId == userId)
        .toList()
      ..sort(
          (ReportModel a, ReportModel b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    _reportSequence += 1;
    final ReportModel saved = ReportModel(
      id: report.id.isEmpty
          ? 'r_${DateTime.now().microsecondsSinceEpoch}'
          : report.id,
      referenceNumber: report.referenceNumber.isEmpty
          ? 'BRGY-${DateTime.now().year}-${_reportSequence.toString().padLeft(3, '0')}'
          : report.referenceNumber,
      userId: report.userId,
      residentName: report.residentName,
      title: report.title,
      category: report.category,
      description: report.description,
      imageUrls: report.imageUrls,
      location: report.location,
      status: report.status,
      adminResponse: report.adminResponse,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
    );
    _reports[saved.id] = saved;
    await _persist();
    return saved;
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    if (!_reports.containsKey(report.id)) {
      throw BackendException('This report no longer exists.');
    }
    _reports[report.id] = report;
    await _persist();
    return report;
  }

  // -------------------------------------------------------- document requests

  @override
  Future<List<DocumentRequestModel>> listDocumentRequests(
      {String? userId}) async {
    final List<DocumentRequestModel> requests = _documents.values
        .where((DocumentRequestModel d) => userId == null || d.userId == userId)
        .toList()
      ..sort((DocumentRequestModel a, DocumentRequestModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  @override
  Future<DocumentRequestModel> createDocumentRequest(
      DocumentRequestModel request) async {
    _documentSequence += 1;
    final DocumentRequestModel saved = DocumentRequestModel(
      id: request.id.isEmpty
          ? 'd_${DateTime.now().microsecondsSinceEpoch}'
          : request.id,
      referenceNumber: request.referenceNumber.isEmpty
          ? 'DOC-${DateTime.now().year}-${_documentSequence.toString().padLeft(3, '0')}'
          : request.referenceNumber,
      userId: request.userId,
      residentName: request.residentName,
      documentType: request.documentType,
      fullName: request.fullName,
      address: request.address,
      purpose: request.purpose,
      contactNumber: request.contactNumber,
      additionalInformation: request.additionalInformation,
      status: request.status,
      adminResponse: request.adminResponse,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );
    _documents[saved.id] = saved;
    await _persist();
    return saved;
  }

  @override
  Future<DocumentRequestModel> updateDocumentRequest(
      DocumentRequestModel request) async {
    if (!_documents.containsKey(request.id)) {
      throw BackendException('This document request no longer exists.');
    }
    _documents[request.id] = request;
    await _persist();
    return request;
  }

  // ------------------------------------------------------------- announcements

  @override
  Future<List<AnnouncementModel>> listAnnouncements(
      {bool publishedOnly = true}) async {
    final List<AnnouncementModel> items = _announcements.values
        .where((AnnouncementModel a) => !publishedOnly || a.published)
        .toList()
      ..sort((AnnouncementModel a, AnnouncementModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<AnnouncementModel> saveAnnouncement(
      AnnouncementModel announcement) async {
    final AnnouncementModel saved = announcement.id.isEmpty
        ? AnnouncementModel(
            id: 'a_${DateTime.now().microsecondsSinceEpoch}',
            title: announcement.title,
            content: announcement.content,
            imageUrl: announcement.imageUrl,
            category: announcement.category,
            published: announcement.published,
            createdBy: announcement.createdBy,
            createdAt: announcement.createdAt,
            updatedAt: announcement.updatedAt,
          )
        : announcement;
    _announcements[saved.id] = saved;
    await _persist();
    return saved;
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    _announcements.remove(id);
    await _persist();
  }

  // ------------------------------------------------------------- notifications

  @override
  Future<List<NotificationModel>> listNotifications(String userId) async {
    final List<NotificationModel> items = _notifications.values
        .where((NotificationModel n) => n.recipientUserId == userId)
        .toList()
      ..sort((NotificationModel a, NotificationModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    await addNotifications(<NotificationModel>[notification]);
  }

  @override
  Future<void> addNotifications(List<NotificationModel> notifications) async {
    for (final NotificationModel notification in notifications) {
      _notifications[notification.id] = notification;
    }
    await _persist();
  }

  @override
  Future<void> markNotificationRead(String notificationId,
      {required bool isRead}) async {
    final NotificationModel? item = _notifications[notificationId];
    if (item == null) return;
    _notifications[notificationId] = item.copyWith(isRead: isRead);
    await _persist();
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    for (final NotificationModel item in _notifications.values.toList()) {
      if (item.recipientUserId == userId) {
        _notifications[item.id] = item.copyWith(isRead: true);
      }
    }
    await _persist();
  }

  // ------------------------------------------------ directory & contacts & map

  @override
  Future<List<DirectoryEntryModel>> listDirectory() async {
    final List<DirectoryEntryModel> items = _directory.values.toList()
      ..sort((DirectoryEntryModel a, DirectoryEntryModel b) =>
          a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<DirectoryEntryModel> saveDirectoryEntry(
      DirectoryEntryModel entry) async {
    final DirectoryEntryModel saved =
        entry.id.isEmpty ? entry.copyWith() : entry;
    final String id = entry.id.isEmpty
        ? 'dir_${DateTime.now().microsecondsSinceEpoch}'
        : entry.id;
    final DirectoryEntryModel withId = DirectoryEntryModel(
      id: id,
      name: saved.name,
      position: saved.position,
      contactNumber: saved.contactNumber,
      office: saved.office,
      description: saved.description,
      isActive: saved.isActive,
      updatedAt: DateTime.now(),
    );
    _directory[id] = withId;
    await _persist();
    return withId;
  }

  @override
  Future<void> deleteDirectoryEntry(String id) async {
    _directory.remove(id);
    await _persist();
  }

  @override
  Future<List<EmergencyContactModel>> listEmergencyContacts() async {
    final List<EmergencyContactModel> items = _emergency.values.toList();
    return items;
  }

  @override
  Future<EmergencyContactModel> saveEmergencyContact(
      EmergencyContactModel contact) async {
    final String id = contact.id.isEmpty
        ? 'em_${DateTime.now().microsecondsSinceEpoch}'
        : contact.id;
    final EmergencyContactModel withId = EmergencyContactModel(
      id: id,
      name: contact.name,
      category: contact.category,
      contactNumber: contact.contactNumber,
      description: contact.description,
      availableHours: contact.availableHours,
      isActive: contact.isActive,
    );
    _emergency[id] = withId;
    await _persist();
    return withId;
  }

  @override
  Future<void> deleteEmergencyContact(String id) async {
    _emergency.remove(id);
    await _persist();
  }

  @override
  Future<List<BarangayLocationModel>> listLocations() async {
    final List<BarangayLocationModel> items = _locations.values.toList();
    return items;
  }

  @override
  Future<BarangayLocationModel> saveLocation(
      BarangayLocationModel location) async {
    final String id = location.id.isEmpty
        ? 'loc_${DateTime.now().microsecondsSinceEpoch}'
        : location.id;
    final BarangayLocationModel withId = BarangayLocationModel(
      id: id,
      name: location.name,
      category: location.category,
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      description: location.description,
      isActive: location.isActive,
    );
    _locations[id] = withId;
    await _persist();
    return withId;
  }

  @override
  Future<void> deleteLocation(String id) async {
    _locations.remove(id);
    await _persist();
  }

  // -------------------------------------------------------------- persistence

  Future<void> _persist() async {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) return;
    final Map<String, dynamic> payload = <String, dynamic>{
      'users': _users.values.map((UserModel u) => u.toMap()).toList(),
      'passwords': _passwords,
      'reports': _reports.values.map((ReportModel r) => r.toMap()).toList(),
      'documents':
          _documents.values.map((DocumentRequestModel d) => d.toMap()).toList(),
      'announcements': _announcements.values
          .map((AnnouncementModel a) => a.toMap())
          .toList(),
      'notifications': _notifications.values
          .map((NotificationModel n) => n.toMap())
          .toList(),
      'directory':
          _directory.values.map((DirectoryEntryModel d) => d.toMap()).toList(),
      'emergency': _emergency.values
          .map((EmergencyContactModel e) => e.toMap())
          .toList(),
      'locations': _locations.values
          .map((BarangayLocationModel l) => l.toMap())
          .toList(),
      'reportSequence': _reportSequence,
      'documentSequence': _documentSequence,
    };
    await prefs.setString(
      storageKey,
      jsonEncode(
        payload,
        toEncodable: (Object? value) =>
            value is DateTime ? value.toIso8601String() : value,
      ),
    );
  }

  void _decode(Map<String, dynamic> map) {
    _users.clear();
    _reports.clear();
    _documents.clear();
    _announcements.clear();
    _notifications.clear();
    _directory.clear();
    _emergency.clear();
    _locations.clear();
    _passwords.clear();

    for (final dynamic raw
        in (map['users'] as List<dynamic>? ?? const <dynamic>[])) {
      final UserModel user =
          UserModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _users[user.id] = user;
    }
    (map['passwords'] as Map<String, dynamic>? ?? const <String, dynamic>{})
        .forEach(
            (String key, dynamic value) => _passwords[key] = value.toString());
    for (final dynamic raw
        in (map['reports'] as List<dynamic>? ?? const <dynamic>[])) {
      final ReportModel report =
          ReportModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _reports[report.id] = report;
    }
    for (final dynamic raw
        in (map['documents'] as List<dynamic>? ?? const <dynamic>[])) {
      final DocumentRequestModel request =
          DocumentRequestModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _documents[request.id] = request;
    }
    for (final dynamic raw
        in (map['announcements'] as List<dynamic>? ?? const <dynamic>[])) {
      final AnnouncementModel item =
          AnnouncementModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _announcements[item.id] = item;
    }
    for (final dynamic raw
        in (map['notifications'] as List<dynamic>? ?? const <dynamic>[])) {
      final NotificationModel item =
          NotificationModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _notifications[item.id] = item;
    }
    for (final dynamic raw
        in (map['directory'] as List<dynamic>? ?? const <dynamic>[])) {
      final DirectoryEntryModel item =
          DirectoryEntryModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _directory[item.id] = item;
    }
    for (final dynamic raw
        in (map['emergency'] as List<dynamic>? ?? const <dynamic>[])) {
      final EmergencyContactModel item =
          EmergencyContactModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _emergency[item.id] = item;
    }
    for (final dynamic raw
        in (map['locations'] as List<dynamic>? ?? const <dynamic>[])) {
      final BarangayLocationModel item =
          BarangayLocationModel.fromMap(Map<String, dynamic>.from(raw as Map));
      _locations[item.id] = item;
    }
    _reportSequence = (map['reportSequence'] as num?)?.toInt() ?? 89;
    _documentSequence = (map['documentSequence'] as num?)?.toInt() ?? 12;

    if (_users.isEmpty) _seed();
  }

  /// Sample records so every screen can be explored before the barangay
  /// publishes official information. Contact numbers are placeholders.
  void _seed() {
    final DateTime now = DateTime.now();
    final UserModel admin = UserModel(
      id: 'u_admin',
      fullName: 'Barangay Admin',
      email: 'admin@barangay.gov.ph',
      contactNumber: '0917-000-0000',
      address: 'Barangay Sumbungan Hall',
      role: UserRole.admin,
      verified: true,
      createdAt: now.subtract(const Duration(days: 400)),
    );
    final UserModel maria = UserModel(
      id: 'u_maria',
      fullName: 'Maria Clara Santos',
      email: 'maria@example.com',
      contactNumber: '0912-345-6789',
      address: '128 Mabini Street, Zone 3',
      householdInfo: 'Household of 5',
      verified: true,
      createdAt: now.subtract(const Duration(days: 120)),
    );
    final UserModel juan = UserModel(
      id: 'u_juan',
      fullName: 'Juan Dela Cruz',
      email: 'juan@example.com',
      contactNumber: '0918-222-3344',
      address: '45 Rizal Avenue, Zone 2',
      createdAt: now.subtract(const Duration(days: 40)),
    );
    for (final UserModel user in <UserModel>[admin, maria, juan]) {
      _users[user.id] = user;
    }
    _passwords[admin.id] = 'Admin123!';
    _passwords[maria.id] = 'Resident123!';
    _passwords[juan.id] = 'Resident123!';

    final List<ReportModel> reports = <ReportModel>[
      ReportModel(
        id: 'r_089',
        referenceNumber: 'BRGY-2026-089',
        userId: maria.id,
        residentName: maria.fullName,
        title: 'Broken street light',
        category: 'Street Lighting',
        description:
            'The street light in front of house 128 has been out since Sunday. '
            'The area is very dark at night, which is unsafe for residents '
            'walking home after work.',
        location: 'Mabini Street, Zone 3',
        status: ReportStatus.inProgress,
        adminResponse:
            'Our maintenance team has inspected the light post. Replacement '
            'parts are scheduled for installation within 48 hours.',
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        imageUrls: const <String>[],
      ),
      ReportModel(
        id: 'r_071',
        referenceNumber: 'BRGY-2026-071',
        userId: maria.id,
        residentName: maria.fullName,
        title: 'Uncollected garbage',
        category: 'Garbage & Sanitation',
        description:
            'Garbage along Rizal Avenue has not been collected for three days. '
            'Residents are worried about the smell and possible dengue.',
        location: 'Rizal Avenue, Zone 2',
        status: ReportStatus.pending,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      ReportModel(
        id: 'r_042',
        referenceNumber: 'BRGY-2026-042',
        userId: maria.id,
        residentName: maria.fullName,
        title: 'Blocked drainage',
        category: 'Drainage & Flooding',
        description:
            'The drainage canal near Bonifacio Street is clogged with plastic '
            'and leaves, causing water to overflow when it rains.',
        location: 'Bonifacio Street',
        status: ReportStatus.solved,
        adminResponse:
            'The drainage line was cleared by the barangay maintenance team on '
            'February 4. Please report again if the blockage returns.',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      ReportModel(
        id: 'r_055',
        referenceNumber: 'BRGY-2026-055',
        userId: juan.id,
        residentName: juan.fullName,
        title: 'Stray dogs near the school',
        category: 'Public Safety Hazard',
        description:
            'Several stray dogs are roaming near the elementary school gate '
            'during dismissal time.',
        location: 'Rizal Avenue, Zone 2',
        status: ReportStatus.pending,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    for (final ReportModel report in reports) {
      _reports[report.id] = report;
    }

    _documents['d_012'] = DocumentRequestModel(
      id: 'd_012',
      referenceNumber: 'DOC-2026-012',
      userId: maria.id,
      residentName: maria.fullName,
      documentType: 'Barangay Clearance',
      fullName: maria.fullName,
      address: '128 Mabini Street, Zone 3',
      purpose: 'Employment requirement',
      contactNumber: maria.contactNumber,
      additionalInformation: 'Will pick up on a Saturday morning.',
      status: DocumentStatus.processing,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _announcements['a_1'] = AnnouncementModel(
      id: 'a_1',
      title: 'Heavy rainfall expected this afternoon',
      content:
          'PAGASA has issued a rainfall advisory for our area. Residents in '
          'low-lying areas are advised to stay alert, prepare emergency bags, '
          'and monitor official barangay channels.\n\n'
          'The Barangay Disaster Risk Reduction and Management Office is on '
          'standby. For emergencies, use the hotlines listed in the Emergency '
          'section of this app.',
      category: 'Disaster Alert',
      createdBy: 'Barangay Admin',
      createdAt: now.subtract(const Duration(hours: 9)),
      updatedAt: now.subtract(const Duration(hours: 9)),
    );
    _announcements['a_2'] = AnnouncementModel(
      id: 'a_2',
      title: 'Free community health check-up',
      content:
          'Visit the Barangay Health Center this Saturday from 8:00 AM to 12:00 '
          'NN for a free blood pressure, blood sugar, and nutrition check-up. '
          'Please bring a valid ID and your health record if available.',
      category: 'Health',
      createdBy: 'Barangay Admin',
      createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
    );
    _announcements['a_3'] = AnnouncementModel(
      id: 'a_3',
      title: 'Road repair along Rizal Avenue',
      content:
          'Road concreting along Rizal Avenue will begin next week. Expect '
          'partial lane closures between 8:00 AM and 4:00 PM. Please use '
          'alternate routes and observe traffic signs.',
      category: 'Infrastructure',
      createdBy: 'Barangay Admin',
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(days: 4)),
    );

    _notifications['n_1'] = NotificationModel(
      id: 'n_1',
      recipientUserId: maria.id,
      title: 'Barangay Tanod Respond Desk',
      message:
          'Electrical Maintenance unit will inspect the street light within 48 hours.',
      type: NotificationType.reportUpdate,
      relatedRecordId: 'r_089',
      createdAt: now.subtract(const Duration(hours: 2)),
    );
    _notifications['n_2'] = NotificationModel(
      id: 'n_2',
      recipientUserId: maria.id,
      title: 'Heavy rainfall advisory',
      message:
          'Residents in low-lying areas are advised to stay alert and monitor '
          'official channels.',
      type: NotificationType.announcement,
      relatedRecordId: 'a_1',
      createdAt: now.subtract(const Duration(hours: 9)),
    );
    _notifications['n_3'] = NotificationModel(
      id: 'n_3',
      recipientUserId: maria.id,
      title: 'Account verification complete',
      message: 'You now have full access to barangay services.',
      type: NotificationType.general,
      isRead: true,
      createdAt: now.subtract(const Duration(days: 2)),
    );

    final List<DirectoryEntryModel> officials = <DirectoryEntryModel>[
      DirectoryEntryModel(
        id: 'dir_1',
        name: 'Jelaine Sumayan',
        position: 'Barangay Captain',
        contactNumber: '0912-345-6789',
        office: 'Barangay Hall',
        description: 'Sample record — replace with official information.',
        updatedAt: now,
      ),
      DirectoryEntryModel(
        id: 'dir_2',
        name: 'Cassandra Noquera',
        position: 'Barangay Secretary',
        contactNumber: '0918-234-5678',
        office: 'Barangay Hall',
        description: 'Sample record — replace with official information.',
        updatedAt: now,
      ),
      DirectoryEntryModel(
        id: 'dir_3',
        name: 'James Paa',
        position: 'Barangay Treasurer',
        contactNumber: '0918-234-5679',
        office: 'Barangay Hall',
        description: 'Sample record — replace with official information.',
        updatedAt: now,
      ),
      DirectoryEntryModel(
        id: 'dir_4',
        name: 'Barangay Office',
        position: 'General Inquiries',
        contactNumber: '(02) 8123 4576',
        office: 'Barangay Hall, Ground Floor',
        description: 'Open Monday to Friday, 8:00 AM – 5:00 PM.',
        updatedAt: now,
      ),
    ];
    for (final DirectoryEntryModel entry in officials) {
      _directory[entry.id] = entry;
    }

    final List<EmergencyContactModel> contacts = <EmergencyContactModel>[
      EmergencyContactModel(
        id: 'em_1',
        name: 'Barangay Tanod Respond Desk',
        category: 'Barangay',
        contactNumber: '(02) 8123 4576',
        description: 'Sample number — barangay hotline.',
      ),
      EmergencyContactModel(
        id: 'em_2',
        name: 'Health Center & Ambulance',
        category: 'Medical',
        contactNumber: '(02) 8234 5678',
        description: 'Sample number — barangay health center.',
      ),
      EmergencyContactModel(
        id: 'em_3',
        name: 'Local PNP Police Station',
        category: 'Police',
        contactNumber: '(02) 8345 6789',
        description: 'Sample number — local police station.',
      ),
      EmergencyContactModel(
        id: 'em_4',
        name: 'BFP Fire Station',
        category: 'Fire',
        contactNumber: '(02) 8456 7890',
        description: 'Sample number — local fire station.',
      ),
      EmergencyContactModel(
        id: 'em_5',
        name: 'Disaster Response Desk',
        category: 'Disaster',
        contactNumber: '(02) 8567 8901',
        description: 'Sample number — barangay disaster response.',
      ),
    ];
    for (final EmergencyContactModel contact in contacts) {
      _emergency[contact.id] = contact;
    }

    final List<BarangayLocationModel> locations = <BarangayLocationModel>[
      BarangayLocationModel(
        id: 'loc_1',
        name: 'Barangay Hall',
        category: 'Barangay Hall',
        address: 'Poblacion, Barangay Sumbungan',
        description: 'Main barangay office and records section.',
      ),
      BarangayLocationModel(
        id: 'loc_2',
        name: 'Barangay Health Center',
        category: 'Health Center',
        address: 'Mabini Street, Zone 3',
        description: 'Maternal care, immunisation and general consultations.',
      ),
      BarangayLocationModel(
        id: 'loc_3',
        name: 'Covered Court',
        category: 'Covered Court',
        address: 'Rizal Avenue, Zone 2',
        description: 'Community events and evacuation point during typhoons.',
      ),
      BarangayLocationModel(
        id: 'loc_4',
        name: 'Sumbungan Elementary School',
        category: 'School',
        address: 'Bonifacio Street',
        description:
            'Public elementary school and designated evacuation center.',
      ),
      BarangayLocationModel(
        id: 'loc_5',
        name: 'Evacuation Center',
        category: 'Evacuation Center',
        address: 'Beside the Covered Court, Rizal Avenue',
        description: 'Primary evacuation site for flood-prone zones.',
      ),
    ];
    for (final BarangayLocationModel location in locations) {
      _locations[location.id] = location;
    }
  }
}
