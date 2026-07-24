import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;

  ApiClient(this._auth, this._client);

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
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('Sign in before calling the API.');
    }
    final data = await postJson('/auth/firebase', {
      'idToken': idToken,
    }, authenticated: false);
    return data['accessToken'] as String;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(FirebaseAuth.instance, http.Client());
});
