import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Document request workflow statuses.
enum DocumentStatus {
  pending,
  processing,
  readyForPickup,
  completed,
  rejected;

  String get label {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.processing:
        return 'Processing';
      case DocumentStatus.readyForPickup:
        return 'Ready for Pickup';
      case DocumentStatus.completed:
        return 'Completed';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }

  Color get foreground {
    switch (this) {
      case DocumentStatus.pending:
        return AppColors.info;
      case DocumentStatus.processing:
        return AppColors.warning;
      case DocumentStatus.readyForPickup:
        return AppColors.primaryDark;
      case DocumentStatus.completed:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.danger;
    }
  }

  Color get background {
    switch (this) {
      case DocumentStatus.pending:
        return AppColors.infoSoft;
      case DocumentStatus.processing:
        return AppColors.warningSoft;
      case DocumentStatus.readyForPickup:
        return AppColors.primarySoft;
      case DocumentStatus.completed:
        return AppColors.successSoft;
      case DocumentStatus.rejected:
        return AppColors.dangerSoft;
    }
  }

  static DocumentStatus fromName(String? value) {
    return DocumentStatus.values.firstWhere(
      (DocumentStatus s) => s.name == value,
      orElse: () => DocumentStatus.pending,
    );
  }
}

class DocumentRequestModel {
  const DocumentRequestModel({
    required this.id,
    required this.referenceNumber,
    required this.userId,
    required this.documentType,
    required this.fullName,
    required this.address,
    required this.purpose,
    required this.contactNumber,
    this.additionalInformation = '',
    this.status = DocumentStatus.pending,
    this.adminResponse = '',
    required this.createdAt,
    required this.updatedAt,
    this.residentName = '',
  });

  final String id;
  final String referenceNumber;
  final String userId;
  final String residentName;
  final String documentType;
  final String fullName;
  final String address;
  final String purpose;
  final String contactNumber;
  final String additionalInformation;
  final DocumentStatus status;
  final String adminResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentRequestModel copyWith({
    DocumentStatus? status,
    String? adminResponse,
    DateTime? updatedAt,
  }) {
    return DocumentRequestModel(
      id: id,
      referenceNumber: referenceNumber,
      userId: userId,
      residentName: residentName,
      documentType: documentType,
      fullName: fullName,
      address: address,
      purpose: purpose,
      contactNumber: contactNumber,
      additionalInformation: additionalInformation,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'requestId': id,
        'referenceNumber': referenceNumber,
        'userId': userId,
        'residentName': residentName,
        'documentType': documentType,
        'fullName': fullName,
        'address': address,
        'purpose': purpose,
        'contactNumber': contactNumber,
        'additionalInformation': additionalInformation,
        'status': status.name,
        'adminResponse': adminResponse,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory DocumentRequestModel.fromMap(Map<String, dynamic> map) {
    return DocumentRequestModel(
      id: (map['requestId'] ?? map['id'] ?? '').toString(),
      referenceNumber: (map['referenceNumber'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      residentName: (map['residentName'] ?? '').toString(),
      documentType: (map['documentType'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      purpose: (map['purpose'] ?? '').toString(),
      contactNumber: (map['contactNumber'] ?? '').toString(),
      additionalInformation: (map['additionalInformation'] ?? '').toString(),
      status: DocumentStatus.fromName(map['status'] as String?),
      adminResponse: (map['adminResponse'] ?? '').toString(),
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
