import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../../models/announcement_model.dart';
import '../../models/directory_model.dart';
import '../../models/document_model.dart';
import '../../models/notification_model.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import 'barangay_backend.dart';

/// Cloud implementation of [BarangayBackend] backed by Firebase.
///
/// * Accounts        → Firebase Authentication (email/password)
/// * Records         → Cloud Firestore collections
/// * Reference no.   → transactional `counters` documents
///
/// The rest of the app talks to this class only through [BarangayBackend],
/// so switching between the offline [LocalBackend] and this cloud backend
/// requires no screen or service changes.
class FirebaseBackend implements BarangayBackend {
  static const String _usersCollection = 'users';
  static const String _reportsCollection = 'reports';
  static const String _documentsCollection = 'document_requests';
  static const String _announcementsCollection = 'announcements';
  static const String _notificationsCollection = 'notifications';
  static const String _directoryCollection = 'directory';
  static const String _emergencyCollection = 'emergency_contacts';
  static const String _locationsCollection = 'locations';
  static const String _countersCollection = 'counters';

  fba.FirebaseAuth get _auth => fba.FirebaseAuth.instance;
  FirebaseFirestore get _store => FirebaseFirestore.instance;

  @override
  Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  // ---------------------------------------------------------------- accounts

  @override
  Future<UserModel?> authenticate(String email, String password) async {
    final String normalised = email.trim().toLowerCase();
    try {
      final fba.UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: normalised, password: password);
      final fba.User firebaseUser = credential.user!;
      final Map<String, dynamic> data =
          await _readOrCreateUserDoc(firebaseUser);
      final UserModel user = UserModel.fromMap(_convert(data));
      if (!user.isActive) {
        await _auth.signOut();
        throw BackendException(
          'This account has been suspended. Please contact the barangay office.',
        );
      }
      return user;
    } on fba.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-email') {
        return null;
      }
      if (e.code == 'too-many-requests') {
        throw BackendException(
          'Too many sign-in attempts. Please wait a moment and try again.',
        );
      }
      if (e.code == 'network-request-failed') {
        throw BackendException(
          'You appear to be offline. Please check your connection.',
        );
      }
      if (e.code == 'operation-not-allowed') {
        throw BackendException(
          'Email and password sign-in is disabled for this Firebase project.',
        );
      }
      throw BackendException('Sign-in failed. Please try again.');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw BackendException(
          'Your credentials were accepted, but Firestore denied access to '
          'your profile. Deploy Firestore rules that allow users to read '
          'their own /users/{uid} profile.',
        );
      }
      throw BackendException(_friendlyFirestoreError(e));
    }
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
    final fba.UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
          email: normalised, password: password);
    } on fba.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw BackendException('An account with this email already exists.');
      }
      if (e.code == 'weak-password') {
        throw BackendException(
          'That password is too weak. Please use at least 6 characters.',
        );
      }
      if (e.code == 'network-request-failed') {
        throw BackendException(_offlineMessage);
      }
      if (e.code == 'operation-not-allowed') {
        throw BackendException(
          'Email and password sign-up is disabled for this Firebase project.',
        );
      }
      rethrow;
    }
    final String uid = credential.user!.uid;
    final UserModel user = UserModel(
      id: uid,
      fullName: fullName.trim(),
      email: normalised,
      contactNumber: contactNumber.trim(),
      address: address.trim(),
      householdInfo: householdInfo.trim(),
      role: UserRole.resident,
      createdAt: DateTime.now(),
    );
    try {
      await _store.collection(_usersCollection).doc(uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw BackendException(_profileWriteError(e));
    }
    return user;
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await _store.collection(_usersCollection).doc(user.id).update(
      <String, dynamic>{
        'fullName': user.fullName.trim(),
        'contactNumber': user.contactNumber.trim(),
        'address': user.address.trim(),
        'householdInfo': user.householdInfo.trim(),
      },
    );
  }

  @override
  Future<void> setAccountStatus(String userId, AccountStatus status) async {
    await _store
        .collection(_usersCollection)
        .doc(userId)
        .update(<String, dynamic>{'accountStatus': status.name});
  }

  @override
  Future<void> changePassword(
      String userId, String currentPassword, String newPassword) async {
    final fba.User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != userId) {
      throw BackendException('You are not signed in.');
    }
    try {
      final fba.AuthCredential credential = fba.EmailAuthProvider.credential(
        email: firebaseUser.email ?? '',
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
    } on fba.FirebaseAuthException {
      throw BackendException('Your current password is incorrect.');
    }
    try {
      await firebaseUser.updatePassword(newPassword);
    } on fba.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw BackendException(
          'That new password is too weak. Please use at least 6 characters.',
        );
      }
      throw BackendException('Could not update the password. Try again.');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fba.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw BackendException('No account was found with that email.');
      }
      if (e.code == 'invalid-email') {
        throw BackendException(
            'That email address does not look right. Please check it.');
      }
      if (e.code == 'network-request-failed') {
        throw BackendException(_offlineMessage);
      }
      rethrow;
    }
  }

  @override
  Future<UserModel?> findUserById(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _store.collection(_usersCollection).doc(userId).get();
      if (!snapshot.exists) return null;
      return UserModel.fromMap(_convert(snapshot.data()!));
    } catch (_) {
      // A stale or expired session should silently drop back to the login.
      return null;
    }
  }

  @override
  Future<List<UserModel>> listUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _store
        .collection(_usersCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            UserModel.fromMap(_convert(doc.data())))
        .toList();
  }

  // ----------------------------------------------------------------- reports

  @override
  Future<List<ReportModel>> listReports({String? userId}) async {
    var query =
        _store.collection(_reportsCollection) as Query<Map<String, dynamic>>;
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    final List<ReportModel> reports = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            ReportModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort(
          (ReportModel a, ReportModel b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    if (report.id.isNotEmpty && report.referenceNumber.isNotEmpty) {
      final DocumentReference<Map<String, dynamic>> ref =
          _store.collection(_reportsCollection).doc(report.id);
      await ref.set(report.toMap());
      return report;
    }
    final int sequence = await _nextSequence('reports');
    final String id = report.id.isEmpty
        ? _store.collection(_reportsCollection).doc().id
        : report.id;
    final ReportModel saved = ReportModel(
      id: id,
      referenceNumber: report.referenceNumber.isEmpty
          ? 'BRGY-${DateTime.now().year}-${sequence.toString().padLeft(3, '0')}'
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
    await _store.collection(_reportsCollection).doc(id).set(saved.toMap());
    return saved;
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _store.collection(_reportsCollection).doc(report.id);
    try {
      await ref.update(_stripId(report.toMap()));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw BackendException('This report no longer exists.');
      }
      rethrow;
    }
    return report;
  }

  // -------------------------------------------------------- document requests

  @override
  Future<List<DocumentRequestModel>> listDocumentRequests(
      {String? userId}) async {
    var query =
        _store.collection(_documentsCollection) as Query<Map<String, dynamic>>;
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    final List<DocumentRequestModel> requests = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            DocumentRequestModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((DocumentRequestModel a, DocumentRequestModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  @override
  Future<DocumentRequestModel> createDocumentRequest(
      DocumentRequestModel request) async {
    if (request.id.isNotEmpty && request.referenceNumber.isNotEmpty) {
      final DocumentReference<Map<String, dynamic>> ref =
          _store.collection(_documentsCollection).doc(request.id);
      await ref.set(request.toMap());
      return request;
    }
    final int sequence = await _nextSequence('documentRequests');
    final String id = request.id.isEmpty
        ? _store.collection(_documentsCollection).doc().id
        : request.id;
    final DocumentRequestModel saved = DocumentRequestModel(
      id: id,
      referenceNumber: request.referenceNumber.isEmpty
          ? 'DOC-${DateTime.now().year}-${sequence.toString().padLeft(3, '0')}'
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
    await _store.collection(_documentsCollection).doc(id).set(saved.toMap());
    return saved;
  }

  @override
  Future<DocumentRequestModel> updateDocumentRequest(
      DocumentRequestModel request) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _store.collection(_documentsCollection).doc(request.id);
    try {
      await ref.update(_stripId(request.toMap()));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw BackendException('This document request no longer exists.');
      }
      rethrow;
    }
    return request;
  }

  // ------------------------------------------------------------ announcements

  @override
  Future<List<AnnouncementModel>> listAnnouncements(
      {bool publishedOnly = true}) async {
    var query = _store.collection(_announcementsCollection)
        as Query<Map<String, dynamic>>;
    if (publishedOnly) {
      query = query.where('published', isEqualTo: true);
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    final List<AnnouncementModel> items = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            AnnouncementModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((AnnouncementModel a, AnnouncementModel b) =>
          b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<AnnouncementModel> saveAnnouncement(
      AnnouncementModel announcement) async {
    final String id = announcement.id.isEmpty
        ? _store.collection(_announcementsCollection).doc().id
        : announcement.id;
    final Map<String, dynamic> map = announcement.toMap();
    map['announcementId'] = id;
    await _store.collection(_announcementsCollection).doc(id).set(map);
    return AnnouncementModel(
      id: id,
      title: announcement.title,
      content: announcement.content,
      imageUrl: announcement.imageUrl,
      category: announcement.category,
      published: announcement.published,
      createdBy: announcement.createdBy,
      createdAt: announcement.createdAt,
      updatedAt: announcement.updatedAt,
    );
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await _store.collection(_announcementsCollection).doc(id).delete();
  }

  // ------------------------------------------------------------ notifications

  @override
  Future<List<NotificationModel>> listNotifications(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _store
        .collection(_notificationsCollection)
        .where('recipientUserId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            NotificationModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((NotificationModel a, NotificationModel b) =>
          b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    await addNotifications(<NotificationModel>[notification]);
  }

  @override
  Future<void> addNotifications(List<NotificationModel> notifications) async {
    final WriteBatch batch = _store.batch();
    for (final NotificationModel notification in notifications) {
      final String id = notification.id.isEmpty
          ? _store.collection(_notificationsCollection).doc().id
          : notification.id;
      final Map<String, dynamic> map = notification.toMap();
      map['notificationId'] = id;
      batch.set(_store.collection(_notificationsCollection).doc(id), map);
    }
    await batch.commit();
  }

  @override
  Future<void> markNotificationRead(String notificationId,
      {required bool isRead}) async {
    await _store
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update(<String, dynamic>{'isRead': isRead});
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _store
        .collection(_notificationsCollection)
        .where('recipientUserId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    if (snapshot.docs.isEmpty) return;
    final WriteBatch batch = _store.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.update(doc.reference, <String, dynamic>{'isRead': true});
    }
    await batch.commit();
  }

  // ------------------------------------------------- directory & map & hotline

  @override
  Future<List<DirectoryEntryModel>> listDirectory() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _store.collection(_directoryCollection).get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            DirectoryEntryModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((DirectoryEntryModel a, DirectoryEntryModel b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<DirectoryEntryModel> saveDirectoryEntry(
      DirectoryEntryModel entry) async {
    final String id = entry.id.isEmpty
        ? _store.collection(_directoryCollection).doc().id
        : entry.id;
    final Map<String, dynamic> map = entry.toMap();
    map['directoryId'] = id;
    await _store.collection(_directoryCollection).doc(id).set(map);
    return DirectoryEntryModel(
      id: id,
      name: entry.name,
      position: entry.position,
      contactNumber: entry.contactNumber,
      office: entry.office,
      description: entry.description,
      isActive: entry.isActive,
      updatedAt: entry.updatedAt,
    );
  }

  @override
  Future<void> deleteDirectoryEntry(String id) async {
    await _store.collection(_directoryCollection).doc(id).delete();
  }

  @override
  Future<List<EmergencyContactModel>> listEmergencyContacts() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _store.collection(_emergencyCollection).get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            EmergencyContactModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((EmergencyContactModel a, EmergencyContactModel b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<EmergencyContactModel> saveEmergencyContact(
      EmergencyContactModel contact) async {
    final String id = contact.id.isEmpty
        ? _store.collection(_emergencyCollection).doc().id
        : contact.id;
    final Map<String, dynamic> map = contact.toMap();
    map['contactId'] = id;
    await _store.collection(_emergencyCollection).doc(id).set(map);
    return EmergencyContactModel(
      id: id,
      name: contact.name,
      category: contact.category,
      contactNumber: contact.contactNumber,
      description: contact.description,
      availableHours: contact.availableHours,
      isActive: contact.isActive,
    );
  }

  @override
  Future<void> deleteEmergencyContact(String id) async {
    await _store.collection(_emergencyCollection).doc(id).delete();
  }

  @override
  Future<List<BarangayLocationModel>> listLocations() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _store.collection(_locationsCollection).get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            BarangayLocationModel.fromMap(_convert(doc.data())))
        .toList()
      ..sort((BarangayLocationModel a, BarangayLocationModel b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<BarangayLocationModel> saveLocation(
      BarangayLocationModel location) async {
    final String id = location.id.isEmpty
        ? _store.collection(_locationsCollection).doc().id
        : location.id;
    final Map<String, dynamic> map = location.toMap();
    map['locationId'] = id;
    await _store.collection(_locationsCollection).doc(id).set(map);
    return BarangayLocationModel(
      id: id,
      name: location.name,
      category: location.category,
      address: location.address,
      latitude: location.latitude,
      longitude: location.longitude,
      description: location.description,
      isActive: location.isActive,
    );
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _store.collection(_locationsCollection).doc(id).delete();
  }

  // ----------------------------------------------------------------- helpers

  /// Atomically increments and returns a shared counter, used to build
  /// human-friendly reference numbers such as `BRGY-2026-091`.
  Future<int> _nextSequence(String key) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _store.collection(_countersCollection).doc(key);
    return _store.runTransaction<int>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(ref);
      final int next = ((snapshot.data()?['seq'] as num?) ?? 0).toInt() + 1;
      transaction.set(ref, <String, dynamic>{'seq': next});
      return next;
    });
  }

  Future<Map<String, dynamic>> _readOrCreateUserDoc(
      fba.User firebaseUser) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _store.collection(_usersCollection).doc(firebaseUser.uid);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
    if (snapshot.exists) return snapshot.data()!;

    // Earlier sign-ups may have created the Auth user but failed before the
    // Firestore profile write. Recreate a resident profile so that user can
    // sign in and complete their profile in the app.
    final String email = (firebaseUser.email ?? '').trim().toLowerCase();
    final String displayName = firebaseUser.displayName?.trim() ?? '';
    final UserModel recovered = UserModel(
      id: firebaseUser.uid,
      fullName: displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
      role: UserRole.resident,
      createdAt: DateTime.now(),
    );
    try {
      await ref.set(recovered.toMap());
    } on FirebaseException catch (e) {
      throw BackendException(_profileWriteError(e));
    }
    return recovered.toMap();
  }

  /// Firestore returns `Timestamp` objects for stored `DateTime` values;
  /// the models expect plain `DateTime`, so convert before decoding.
  static Map<String, dynamic> _convert(Map<String, dynamic> source) {
    return source.map<String, dynamic>(
      (String key, Object? value) =>
          MapEntry<String, dynamic>(key, _convertValue(value)),
    );
  }

  static Object? _convertValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is List<dynamic>) {
      return value.map<Object?>(_convertValue).toList();
    }
    if (value is Map<String, dynamic>) return _convert(value);
    return value;
  }

  /// `update()` cannot include the document id itself when the value key
  /// differs from the id field; the id stays stable, so drop it.
  static Map<String, dynamic> _stripId(Map<String, dynamic> map) {
    return Map<String, dynamic>.from(map)..remove('id');
  }

  static const String _offlineMessage =
      'You appear to be offline. Please check your connection and try again.';

  static String _profileWriteError(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Your Firebase Authentication account exists, but its profile '
          'could not be saved. Deploy Firestore rules that allow a signed-in '
          'user to create their own /users/{uid} profile, then sign in again.';
    }
    if (e.code == 'unavailable' || e.code == 'network-request-failed') {
      return 'Your Firebase Authentication account exists, but its profile '
          'could not be saved because the connection failed. Check your '
          'connection and sign in again to finish setting up the profile.';
    }
    return 'Your Firebase Authentication account exists, but its Firestore '
        'profile could not be saved (${e.code}). Sign in again to retry.';
  }

  static String _friendlyFirestoreError(FirebaseException e) {
    if (e.code == 'unavailable' || e.code == 'network-request-failed') {
      return _offlineMessage;
    }
    if (e.code == 'permission-denied') {
      return 'You do not have permission to do that.';
    }
    return 'Something went wrong. Please try again.';
  }
}
