import '../models/document_model.dart';
import '../models/user_model.dart';
import 'backend/barangay_backend.dart';

class DocumentService {
  DocumentService(this._backend);

  final BarangayBackend _backend;

  Future<List<DocumentRequestModel>> fetchRequests({UserModel? forUser}) {
    return _backend.listDocumentRequests(userId: forUser?.id);
  }

  Future<DocumentRequestModel> submitRequest({
    required UserModel resident,
    required String documentType,
    required String fullName,
    required String address,
    required String purpose,
    required String contactNumber,
    String additionalInformation = '',
  }) {
    final DateTime now = DateTime.now();
    return _backend.createDocumentRequest(
      DocumentRequestModel(
        id: '',
        referenceNumber: '',
        userId: resident.id,
        residentName: resident.fullName,
        documentType: documentType,
        fullName: fullName.trim(),
        address: address.trim(),
        purpose: purpose.trim(),
        contactNumber: contactNumber.trim(),
        additionalInformation: additionalInformation.trim(),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<DocumentRequestModel> updateStatus({
    required DocumentRequestModel request,
    required DocumentStatus status,
    String? adminResponse,
  }) {
    return _backend.updateDocumentRequest(
      request.copyWith(
        status: status,
        adminResponse: adminResponse ?? request.adminResponse,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
