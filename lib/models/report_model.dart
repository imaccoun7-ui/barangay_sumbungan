import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Report workflow statuses required by the concept paper.
enum ReportStatus {
  pending,
  inProgress,
  solved;

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In progress';
      case ReportStatus.solved:
        return 'Solved';
    }
  }

  String get adminLabel => this == ReportStatus.pending ? 'Open' : label;

  Color get foreground {
    switch (this) {
      case ReportStatus.pending:
        return AppColors.info;
      case ReportStatus.inProgress:
        return AppColors.warning;
      case ReportStatus.solved:
        return AppColors.success;
    }
  }

  Color get background {
    switch (this) {
      case ReportStatus.pending:
        return AppColors.infoSoft;
      case ReportStatus.inProgress:
        return AppColors.warningSoft;
      case ReportStatus.solved:
        return AppColors.successSoft;
    }
  }

  static ReportStatus fromName(String? value) {
    return ReportStatus.values.firstWhere(
      (ReportStatus s) => s.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

class ReportModel {
  const ReportModel({
    required this.id,
    required this.referenceNumber,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    this.imageUrls = const <String>[],
    this.location = '',
    this.status = ReportStatus.pending,
    this.adminResponse = '',
    required this.createdAt,
    required this.updatedAt,
    this.residentName = '',
  });

  final String id;
  final String referenceNumber;
  final String userId;
  final String residentName;
  final String title;
  final String category;
  final String description;
  final List<String> imageUrls;
  final String location;
  final ReportStatus status;
  final String adminResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel copyWith({
    String? title,
    String? category,
    String? description,
    List<String>? imageUrls,
    String? location,
    ReportStatus? status,
    String? adminResponse,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id,
      referenceNumber: referenceNumber,
      userId: userId,
      residentName: residentName,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Progress through the resolution timeline (Fidelity V1 report details).
  int get progressStep {
    switch (status) {
      case ReportStatus.pending:
        return 1;
      case ReportStatus.inProgress:
        return 3;
      case ReportStatus.solved:
        return 4;
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'reportId': id,
        'referenceNumber': referenceNumber,
        'userId': userId,
        'residentName': residentName,
        'title': title,
        'category': category,
        'description': description,
        'imageUrls': imageUrls,
        'location': location,
        'status': status.name,
        'adminResponse': adminResponse,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: (map['reportId'] ?? map['id'] ?? '').toString(),
      referenceNumber: (map['referenceNumber'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      residentName: (map['residentName'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      location: (map['location'] ?? '').toString(),
      status: ReportStatus.fromName(map['status'] as String?),
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
