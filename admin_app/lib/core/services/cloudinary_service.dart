import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart';

class CloudinaryService {
  final ApiClient _api;

  CloudinaryService(this._api);

  Future<String> uploadImage({
    required List<int> bytes,
    required String folder,
    String fileName = 'upload',
  }) async {
    final safeFolder = folder
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'^/+|/+$'), '');
    final apiFolder = _apiFolderFor(safeFolder);

    try {
      final data = await _api.postJson('/media/upload-token', {
        'folder': apiFolder,
      });
      final signature = data['signature'] as String;
      final timestamp = data['timestamp'] as int;
      final cloudName = data['cloudName'] as String;
      final apiKey = data['apiKey'] as String;
      final targetFolder = data['folder'] as String;

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature
        ..fields['folder'] = targetFolder
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: fileName),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;
        await _api.postJson('/media/complete', {
          'publicId': jsonResponse['public_id'],
          'url': secureUrl,
          'resourceType': jsonResponse['resource_type'] ?? 'image',
          'format': jsonResponse['format'],
          'bytes': jsonResponse['bytes'],
          'folder': apiFolder,
        });
        return secureUrl;
      } else {
        throw Exception('Cloudinary upload failed: $responseBody');
      }
    } catch (e) {
      debugPrint('CloudinaryService Error: $e');
      rethrow;
    }
  }

  String _apiFolderFor(String folder) {
    if (folder == 'services') return 'service-media';
    if (folder == 'tours' || folder.startsWith('tours/')) return 'tour-media';
    return folder;
  }
}

// Riverpod provider — uses ApiClient's cached JWT, no duplicate /auth/firebase.
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService(ref.watch(apiClientProvider));
});
