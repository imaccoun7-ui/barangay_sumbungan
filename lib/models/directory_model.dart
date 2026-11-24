class DirectoryEntryModel {
  const DirectoryEntryModel({
    required this.id,
    required this.name,
    required this.position,
    required this.contactNumber,
    this.office = '',
    this.description = '',
    this.isActive = true,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String position;
  final String contactNumber;
  final String office;
  final String description;
  final bool isActive;
  final DateTime updatedAt;

  DirectoryEntryModel copyWith({
    String? name,
    String? position,
    String? contactNumber,
    String? office,
    String? description,
    bool? isActive,
  }) {
    return DirectoryEntryModel(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      contactNumber: contactNumber ?? this.contactNumber,
      office: office ?? this.office,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'directoryId': id,
        'name': name,
        'position': position,
        'contactNumber': contactNumber,
        'office': office,
        'description': description,
        'isActive': isActive,
        'updatedAt': updatedAt,
      };

  factory DirectoryEntryModel.fromMap(Map<String, dynamic> map) {
    return DirectoryEntryModel(
      id: (map['directoryId'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      position: (map['position'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? '').toString(),
      office: (map['office'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isActive: map['isActive'] != false,
      updatedAt: _date(map['updatedAt']),
    );
  }
}

class EmergencyContactModel {
  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.category,
    required this.contactNumber,
    this.description = '',
    this.availableHours = 'Available 24/7',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String category;
  final String contactNumber;
  final String description;
  final String availableHours;
  final bool isActive;

  EmergencyContactModel copyWith({
    String? name,
    String? category,
    String? contactNumber,
    String? description,
    String? availableHours,
    bool? isActive,
  }) {
    return EmergencyContactModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      availableHours: availableHours ?? this.availableHours,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'contactId': id,
        'name': name,
        'category': category,
        'contactNumber': contactNumber,
        'description': description,
        'availableHours': availableHours,
        'isActive': isActive,
      };

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      id: (map['contactId'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? 'Barangay').toString(),
      contactNumber: (map['contactNumber'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      availableHours: (map['availableHours'] ?? 'Available 24/7').toString(),
      isActive: map['isActive'] != false,
    );
  }
}

class BarangayLocationModel {
  const BarangayLocationModel({
    required this.id,
    required this.name,
    required this.category,
    this.address = '',
    this.latitude = 0,
    this.longitude = 0,
    this.description = '',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final bool isActive;

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  BarangayLocationModel copyWith({
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    bool? isActive,
  }) {
    return BarangayLocationModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'locationId': id,
        'name': name,
        'category': category,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'isActive': isActive,
      };

  factory BarangayLocationModel.fromMap(Map<String, dynamic> map) {
    return BarangayLocationModel(
      id: (map['locationId'] ?? map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      category: (map['category'] ?? 'Other Facility').toString(),
      address: (map['address'] ?? '').toString(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      description: (map['description'] ?? '').toString(),
      isActive: map['isActive'] != false,
    );
  }
}

DateTime _date(Object? value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
