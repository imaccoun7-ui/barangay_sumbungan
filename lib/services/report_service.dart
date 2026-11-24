import '../models/report_model.dart';
import '../models/user_model.dart';
import 'backend/barangay_backend.dart';

class ReportService {
  ReportService(this._backend);

  final BarangayBackend _backend;

  Future<List<ReportModel>> fetchReports({UserModel? forUser}) {
    return _backend.listReports(userId: forUser?.id);
  }

  Future<ReportModel> submitReport({
    required UserModel resident,
    required String title,
    required String category,
    required String description,
    required String location,
    List<String> imageUrls = const <String>[],
  }) {
    final DateTime now = DateTime.now();
    return _backend.createReport(
      ReportModel(
        id: '',
        referenceNumber: '',
        userId: resident.id,
        residentName: resident.fullName,
        title: title.trim(),
        category: category,
        description: description.trim(),
        imageUrls: imageUrls,
        location: location.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<ReportModel> updateStatus({
    required ReportModel report,
    required ReportStatus status,
    String? adminResponse,
  }) {
    return _backend.updateReport(
      report.copyWith(
        status: status,
        adminResponse: adminResponse ?? report.adminResponse,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
