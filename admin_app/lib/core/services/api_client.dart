import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;

  ApiClient(this._auth, this._client);

  // ── Cached backend JWT ────────────────────────────────────────────────────
  String? _cachedAccessToken;
  DateTime? _tokenExpiry;
  String? _cachedFirebaseUid;

  /// Seed an already-fetched token (e.g. from AuthNotifier after login)
  /// so the first API call doesn't need to hit /auth/firebase again.
  void seedToken(String token) {
    final user = _auth.currentUser;
    if (user == null) return;
    _cachedAccessToken = token;
    _cachedFirebaseUid = user.uid;
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 14));
  }

  void clearTokenCache() {
    _cachedAccessToken = null;
    _tokenExpiry = null;
    _cachedFirebaseUid = null;
  }

  // ── HTTP helpers ─────────────────────────────────────────────────────────

  Future<dynamic> getJson(String path) async {
    final response = await _client.get(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer ${await _accessToken()}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _json('POST', path, body);
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _json('PATCH', path, body);
  }

  Future<void> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('${Env.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer ${await _accessToken()}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<Map<String, dynamic>> _json(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final request = http.Request(method, Uri.parse('${Env.apiBaseUrl}$path'))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _accessToken()}',
      })
      ..body = jsonEncode(body);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    return response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<String> _accessToken() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception('Sign in before calling the API.');
    }

    final now = DateTime.now();
    // Reuse cached token if still valid and for the same Firebase user
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        now.isBefore(_tokenExpiry!) &&
        _cachedFirebaseUid == firebaseUser.uid) {
      return _cachedAccessToken!;
    }

    // Fetch a fresh backend JWT via /auth/firebase
    final idToken = await firebaseUser.getIdToken();
    final response = await _client.post(
      Uri.parse('${Env.apiBaseUrl}/auth/firebase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    final token = (jsonDecode(response.body) as Map<String, dynamic>)['accessToken'] as String;
    _cachedAccessToken = token;
    _cachedFirebaseUid = firebaseUser.uid;
    // Cache for 14 minutes (backend JWT TTL is 15 min)
    _tokenExpiry = now.add(const Duration(minutes: 14));
    return token;
  }

  String _errorMessage(http.Response response) {
    try {
      return (jsonDecode(response.body) as Map<String, dynamic>)['error']
              ?.toString() ??
          'API request failed';
    } catch (_) {
      return 'API request failed';
    }
  }
}

// keepAlive: true — Riverpod never disposes this provider, preserving the token cache.
final apiClientProvider = Provider<ApiClient>((ref) {
  ref.keepAlive();
  return ApiClient(FirebaseAuth.instance, http.Client());
});
