import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import '../config/env.dart';

class CloudinaryService {
  final FirebaseAuth _auth;
  final http.Client _client;
  final ApiClient? _api;

  CloudinaryService({
    FirebaseAuth? auth,
    http.Client? client,
    this._api,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

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
      final data = await _postJson(
        '/media/upload-token',
        {'folder': apiFolder},
      );
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
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;
        await _postJson('/media/complete', {
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

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final api = _api;
    if (api != null) return api.postJson(path, body);

    final accessToken = await _apiAccessToken();
    final response = await _client.post(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['error'] ?? 'API request failed');
    }
    return decoded;
  }

  Future<String> _apiAccessToken() async {
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('Sign in before uploading images.');
    }
    final response = await _client.post(
      Uri.parse('${Env.apiBaseUrl}/auth/firebase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['error'] ?? 'API request failed');
    }
    return decoded['accessToken'] as String;
  }

  String _apiFolderFor(String folder) {
    if (folder == 'services') return 'service-media';
    if (folder == 'tours' || folder.startsWith('tours/')) return 'tour-media';
    return folder;
  }
}
