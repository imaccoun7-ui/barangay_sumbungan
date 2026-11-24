import '../models/directory_model.dart';
import 'backend/barangay_backend.dart';

class DirectoryService {
  DirectoryService(this._backend);

  final BarangayBackend _backend;

  Future<List<DirectoryEntryModel>> fetchDirectory() => _backend.listDirectory();

  Future<DirectoryEntryModel> saveEntry(DirectoryEntryModel entry) =>
      _backend.saveDirectoryEntry(entry);

  Future<void> deleteEntry(String id) => _backend.deleteDirectoryEntry(id);

  Future<List<EmergencyContactModel>> fetchEmergencyContacts() =>
      _backend.listEmergencyContacts();

  Future<EmergencyContactModel> saveEmergencyContact(EmergencyContactModel contact) =>
      _backend.saveEmergencyContact(contact);

  Future<void> deleteEmergencyContact(String id) =>
      _backend.deleteEmergencyContact(id);

  Future<List<BarangayLocationModel>> fetchLocations() => _backend.listLocations();

  Future<BarangayLocationModel> saveLocation(BarangayLocationModel location) =>
      _backend.saveLocation(location);

  Future<void> deleteLocation(String id) => _backend.deleteLocation(id);
}
