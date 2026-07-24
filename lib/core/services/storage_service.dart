import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';

/// Uploads picked images through the API's signed Cloudinary flow.
class StorageService {
  final ApiClient _api;

  StorageService(this._api);

  Future<String> uploadImage(XFile file, String path) async {
    final folder = _folderFor(path);
    final uploadToken = await _api.postJson(
      '/media/upload-token',
      {'folder': folder},
    );

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/${uploadToken['cloudName']}/image/upload',
      ),
    )
      ..fields['api_key'] = uploadToken['apiKey'].toString()
      ..fields['timestamp'] = uploadToken['timestamp'].toString()
      ..fields['signature'] = uploadToken['signature'].toString()
      ..fields['folder'] = uploadToken['folder'].toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final uploaded = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = uploaded['secure_url'] as String;
    await _api.postJson('/media/complete', {
      'publicId': uploaded['public_id'],
      'url': secureUrl,
      'resourceType': uploaded['resource_type'] ?? 'image',
      'format': uploaded['format'],
      'bytes': uploaded['bytes'],
      'folder': folder,
    });
    return secureUrl;
  }

  String _folderFor(String path) {
    if (path.startsWith('users/')) return 'profile-media';
    if (path.startsWith('reviews/')) return 'review-media';
    if (path.startsWith('concierge_threads/')) return 'concierge-attachments';
    throw ArgumentError('Unsupported upload path: $path');
  }
}

/// Provider for the StorageService instance.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(apiClientProvider));
});
