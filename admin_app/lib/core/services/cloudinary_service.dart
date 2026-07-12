import 'package:firebase_storage/firebase_storage.dart';

class CloudinaryService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required List<int> bytes,
    required String folder,
    String fileName = 'upload',
  }) async {
    final safeFolder = folder
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'^/+|/+$'), '');
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path =
        'public/$safeFolder/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: _contentTypeFor(fileName));
    final snapshot = await ref.putData(bytes, metadata);
    return snapshot.ref.getDownloadURL();
  }

  String _contentTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
