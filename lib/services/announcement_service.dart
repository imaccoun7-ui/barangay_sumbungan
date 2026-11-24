import '../models/announcement_model.dart';
import '../models/user_model.dart';
import 'backend/barangay_backend.dart';

class AnnouncementService {
  AnnouncementService(this._backend);

  final BarangayBackend _backend;

  Future<List<AnnouncementModel>> fetch({bool publishedOnly = true}) =>
      _backend.listAnnouncements(publishedOnly: publishedOnly);

  Future<AnnouncementModel> publish({
    required UserModel author,
    AnnouncementModel? existing,
    required String title,
    required String content,
    required String category,
    String imageUrl = '',
    bool published = true,
  }) {
    final DateTime now = DateTime.now();
    final AnnouncementModel model = existing == null
        ? AnnouncementModel(
            id: '',
            title: title.trim(),
            content: content.trim(),
            imageUrl: imageUrl,
            category: category,
            published: published,
            createdBy: author.fullName,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            title: title.trim(),
            content: content.trim(),
            imageUrl: imageUrl,
            category: category,
            published: published,
            updatedAt: now,
          );
    return _backend.saveAnnouncement(model);
  }

  Future<void> delete(String id) => _backend.deleteAnnouncement(id);
}
