/// Roles supported by the application.
enum UserRole {
  resident,
  admin;

  static UserRole fromName(String? value) {
    return UserRole.values.firstWhere(
      (UserRole role) => role.name == value,
      orElse: () => UserRole.resident,
    );
  }

  String get label => this == UserRole.admin ? 'Administrator' : 'Resident';
}

enum AccountStatus {
  active,
  suspended;

  static AccountStatus fromName(String? value) => AccountStatus.values
      .firstWhere((AccountStatus s) => s.name == value,
          orElse: () => AccountStatus.active);
}

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.contactNumber = '',
    this.address = '',
    this.householdInfo = '',
    this.role = UserRole.resident,
    this.accountStatus = AccountStatus.active,
    this.verified = false,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final String address;
  final String householdInfo;
  final UserRole role;
  final AccountStatus accountStatus;
  final bool verified;
  final DateTime createdAt;

  bool get isAdmin => role == UserRole.admin;
  bool get isActive => accountStatus == AccountStatus.active;

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String get firstName {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? contactNumber,
    String? address,
    String? householdInfo,
    UserRole? role,
    AccountStatus? accountStatus,
    bool? verified,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      householdInfo: householdInfo ?? this.householdInfo,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      verified: verified ?? this.verified,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': id,
        'fullName': fullName,
        'email': email,
        'contactNumber': contactNumber,
        'address': address,
        'householdInfo': householdInfo,
        'role': role.name,
        'accountStatus': accountStatus.name,
        'verified': verified,
        'createdAt': createdAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['userId'] ?? map['id'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      householdInfo: (map['householdInfo'] ?? '').toString(),
      role: UserRole.fromName(map['role'] as String?),
      accountStatus: AccountStatus.fromName(map['accountStatus'] as String?),
      verified: map['verified'] == true,
      createdAt: _toDate(map['createdAt']),
    );
  }
}

DateTime _toDate(Object? value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
