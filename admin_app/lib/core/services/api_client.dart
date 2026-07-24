import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/env.dart';

class ApiClient {
  final FirebaseAuth _auth;
  final http.Client _client;

  ApiClient(this._auth, this._client);

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

  Future<String> _accessToken() async {
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('Sign in before calling the API.');
    }
    final response = await _client.post(
      Uri.parse('${Env.apiBaseUrl}/auth/firebase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['accessToken']
        as String;
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

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(FirebaseAuth.instance, http.Client());
});
