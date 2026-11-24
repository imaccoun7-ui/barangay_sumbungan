import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Handles evidence photo capture for reports and announcement images.
///
/// When Firebase is available, photos are uploaded to Cloud Storage and the
/// stored value is a public HTTPS download URL (`isRemote == true`). Without
/// Firebase the photo path is kept locally so the flow stays usable offline.
class StorageService {
  StorageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  bool _remote = false;
  bool get isRemote => _remote;

  /// Marks the service to upload to Cloud Storage. Called by [FirebaseBackend]
  /// at startup once Firebase has been initialised.
  Future<void> enableCloud() async {
    try {
      if (Firebase.apps.isEmpty) return;
      final FirebaseStorage storage = FirebaseStorage.instance;
      // Poke the bucket so misconfiguration surfaces early with a clear flag.
      _remote = storage.app.options.storageBucket?.isNotEmpty ?? false;
    } catch (_) {
      _remote = false;
    }
  }

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (file == null) return null;
    final int length = await file.length();
    if (length > maxPhotoBytes) {
      throw const StorageException(
        'That photo is larger than 5 MB. Please choose a smaller image.',
      );
    }
    return file;
  }

  /// Uploads the photo to Cloud Storage and returns its HTTPS URL, or keeps
  /// the local file path when cloud storage is unavailable.
  Future<String> upload(XFile file) async {
    if (!_remote) return file.path;
    try {
      final String uid = fba.FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      final String extension = _extensionOf(file.path);
      final Reference ref = FirebaseStorage.instance.ref().child(
          'evidence/$uid/${DateTime.now().millisecondsSinceEpoch}_'
          '${_randomSuffix()}.$extension');
      final TaskSnapshot snapshot = await ref.putData(await file.readAsBytes());
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException {
      // Keep the report usable even if the upload fails.
      return file.path;
    }
  }

  static String _extensionOf(String path) {
    final int dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return 'jpg';
    return path.substring(dot + 1).toLowerCase();
  }

  static String _randomSuffix() {
    const String alphabet =
        'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List<String>.generate(
        6, (int i) => alphabet[random.nextInt(alphabet.length)]).join();
  }
}

class StorageException implements Exception {
  const StorageException(this.message);
  final String message;
  @override
  String toString() => message;
}
