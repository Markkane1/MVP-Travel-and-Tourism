import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;

  ApiClient(this._auth, this._client);

  String? _cachedAccessToken;
  DateTime? _tokenExpiry;
  String? _cachedFirebaseUid;

  void clearTokenCache() {
    _cachedAccessToken = null;
    _tokenExpiry = null;
    _cachedFirebaseUid = null;
  }

  Future<dynamic> getJson(String path, {bool authenticated = false}) async {
    final response = await _client.get(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {
        if (authenticated) 'Authorization': 'Bearer ${await _accessToken()}',
      },
    );
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded is Map
            ? decoded['error'] ?? 'API request failed'
            : 'API request failed',
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = true,
  }) async {
    final response = await _client.post(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (authenticated) 'Authorization': 'Bearer ${await _accessToken()}',
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['error'] ?? 'API request failed');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.patch(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _accessToken()}',
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(decoded['error'] ?? 'API request failed');
    }
    return decoded;
  }

  Future<void> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer ${await _accessToken()}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(decoded['error'] ?? 'API request failed');
    }
  }

  Future<String> _accessToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Sign in before calling the API.');
    }
    final now = DateTime.now();
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!) &&
        _cachedFirebaseUid == user.uid) {
      return _cachedAccessToken!;
    }

    final idToken = await user.getIdToken();
    final data = await postJson('/auth/firebase', {
      'idToken': idToken,
    }, authenticated: false);
    final token = data['accessToken'] as String;
    _cachedAccessToken = token;
    _cachedFirebaseUid = user.uid;
    _tokenExpiry = now.add(const Duration(minutes: 14));
    return token;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  ref.keepAlive();
  return ApiClient(FirebaseAuth.instance, http.Client());
});
