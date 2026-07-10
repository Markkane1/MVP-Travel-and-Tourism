import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for uploading images to Cloudinary via unsigned upload preset.
///
/// Architecture note: this is a pure data-layer service. It has no Flutter
/// widget dependencies and can be tested independently.
///
/// Setup:
///   1. Create a free Cloudinary account at https://cloudinary.com
///   2. Go to Settings → Upload → Upload presets → Add upload preset
///   3. Set signing mode to "Unsigned"
///   4. Replace the constants below with your own values
class CloudinaryService {
  // ─── Configuration ────────────────────────────────────────────────────────
  // Replace these with your actual Cloudinary credentials.
  // These are safe to embed in a client app when using an UNSIGNED upload preset.
  static const String _cloudName = 'YOUR_CLOUD_NAME'; // e.g. 'mvp-travels'
  static const String _uploadPreset = 'YOUR_UNSIGNED_PRESET'; // e.g. 'mvp_admin_uploads'

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Uploads raw image bytes to Cloudinary and returns the secure public URL.
  ///
  /// [bytes]  - The image file as bytes (from file_picker)
  /// [folder] - Cloudinary folder to organize uploads (e.g. 'tours/heroes')
  /// [fileName] - Suggested file name for the upload
  Future<String> uploadImage({
    required Uint8List bytes,
    required String folder,
    String fileName = 'upload',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final secureUrl = json['secure_url'] as String?;
        if (secureUrl == null || secureUrl.isEmpty) {
          throw Exception('Cloudinary returned no URL in response.');
        }
        return secureUrl;
      } else {
        final errorBody = response.body;
        throw Exception(
          'Cloudinary upload failed (${response.statusCode}): $errorBody',
        );
      }
    } catch (e) {
      debugPrint('CloudinaryService.uploadImage error: $e');
      rethrow;
    }
  }
}
