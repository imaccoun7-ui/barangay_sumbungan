/// Application-wide constants shared by the UI and the service layer.
class AppConstants {
  AppConstants._();

  static const String appName = 'Barangay Sumbungan';
  static const String tagline = 'Ang Boses at Saklolo ng Bawat Barangay.';
  static const String barangayName = 'Barangay Sumbungan';
  static const String sampleDataNotice =
      'Sample records are shown until the barangay administrator publishes '
      'official information.';

  /// Firestore collection names (see `FirestoreSchema` in the docs).
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String documentRequestsCollection = 'documentRequests';
  static const String announcementsCollection = 'announcements';
  static const String notificationsCollection = 'notifications';
  static const String directoryCollection = 'directory';
  static const String emergencyContactsCollection = 'emergencyContacts';
  static const String locationsCollection = 'barangayLocations';

  static const int maxReportPhotos = 5;

  static const List<String> reportCategories = <String>[
    'Street Lighting',
    'Garbage & Sanitation',
    'Drainage & Flooding',
    'Roads & Sidewalks',
    'Peace & Order',
    'Public Safety Hazard',
    'Others',
  ];

  static const List<String> documentTypes = <String>[
    'Barangay Clearance',
    'Barangay Certificate',
    'Certificate of Indigency',
    'Certificate of Residency',
    'Business Clearance',
  ];

  static const List<String> announcementCategories = <String>[
    'Announcements',
    'Health',
    'Infrastructure',
    'Disaster Alert',
  ];

  static const List<String> locationCategories = <String>[
    'Barangay Hall',
    'Health Center',
    'Covered Court',
    'School',
    'Evacuation Center',
    'Other Facility',
  ];

  static const List<String> emergencyCategories = <String>[
    'Barangay',
    'Police',
    'Fire',
    'Medical',
    'Disaster',
  ];
}
