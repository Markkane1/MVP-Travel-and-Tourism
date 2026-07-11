// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = await _readFirebaseConfig();
  final email =
      Platform.environment['SEED_EMAIL'] ?? 'codex.demo.mvptravel@gmail.com';
  final password = Platform.environment['SEED_PASSWORD'] ?? 'Codex1234!';

  final auth = await _authenticateEmailUser(
    apiKey: config.apiKey,
    email: email,
    password: password,
  );
  if (auth == null) {
    print('Failed to authenticate demo user.');
    exitCode = 1;
    return;
  }

  final uid = auth['localId'] as String;
  final idToken = auth['idToken'] as String;
  final headers = {'Authorization': 'Bearer $idToken'};

  await _setDoc(
    projectId: config.projectId,
    path: 'users/$uid',
    headers: headers,
    data: {
      'displayName': 'Codex Demo',
      'email': email,
      'photoUrl':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=300',
      'tier': 'Gold',
      'loyaltyPoints': 1200,
      'milesTraveled': 18450,
      'conciergeId': 'concierge-elena',
      'notificationPrefs': {
        'bookingUpdates': true,
        'promotions': true,
        'conciergeMessages': true,
      },
      'preferences': {
        'dietary': 'Vegetarian',
        'seat': 'Aisle',
        'hotelClass': 'Luxury',
      },
      'createdAt': DateTime.now().subtract(const Duration(days: 40)),
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'users/$uid/paymentMethods/demo-card',
    headers: headers,
    data: {'brand': 'Visa', 'last4': '4242', 'isDefault': true},
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'users/$uid/savedTours/overwater-villas',
    headers: headers,
    data: {
      'tourId': 'overwater-villas',
      'savedAt': DateTime.now().subtract(const Duration(days: 3)),
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'concierges/concierge-elena',
    headers: headers,
    data: {
      'name': 'Elena',
      'role': 'Senior Travel Specialist',
      'specialty': 'Luxury Safaris & Lodges',
      'languages': 'English, Spanish, French',
      'photoUrl':
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400',
      'isOnline': true,
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'concierge_threads/$uid',
    headers: headers,
    data: {
      'typing': false,
      'lastMessage':
          'Welcome back. Your Kyoto follow-up is ready whenever you are.',
      'lastMessageAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'concierge_threads/$uid/messages/demo-message',
    headers: headers,
    data: {
      'senderId': uid,
      'senderType': 'user',
      'text': 'Hi Elena, I would like a Kyoto follow-up for my completed trip.',
      'attachmentUrl': null,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'bookings/demo-completed-kyoto',
    headers: headers,
    data: {
      'id': 'demo-completed-kyoto',
      'userId': uid,
      'tourId': 'kyoto-walk',
      'tourSnapshot': {
        'title': 'Kyoto Heritage Walk',
        'heroImageUrl':
            'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800',
        'destination': 'Kyoto, Japan',
      },
      'tourDate': DateTime.now().subtract(const Duration(days: 10)),
      'adults': 2,
      'children': 0,
      'privateVehicle': false,
      'groupSizeOption': 'Shared',
      'pickupLocation': 'Kyoto Station',
      'specialRequests': 'Late temple visit',
      'totalPrice': 3600.0,
      'currency': 'USD',
      'status': 'completed',
      'bookingReferenceCode': 'MVP-DEMO-001',
      'reviewed': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 40)),
    },
  );

  await _setDoc(
    projectId: config.projectId,
    path: 'notifications/$uid/items/demo-booking-confirmed',
    headers: headers,
    data: {
      'title': 'Kyoto trip completed',
      'body': 'Your Kyoto booking is ready for review.',
      'type': 'booking',
      'deepLink': '/trips?segment=history',
      'read': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
    },
  );

  print('Seeded demo user state for $uid');
}

Future<_FirebaseConfig> _readFirebaseConfig() async {
  final content = await File('lib/firebase_options.dart').readAsString();
  final apiKeyMatch = RegExp(r"apiKey:\s*'([^']+)'").firstMatch(content);
  final projectIdMatch = RegExp(r"projectId:\s*'([^']+)'").firstMatch(content);
  if (apiKeyMatch == null || projectIdMatch == null) {
    throw StateError('Could not parse Firebase config.');
  }
  return _FirebaseConfig(
    apiKey: apiKeyMatch.group(1)!,
    projectId: projectIdMatch.group(1)!,
  );
}

Future<Map<String, dynamic>?> _authenticateEmailUser({
  required String apiKey,
  required String email,
  required String password,
}) async {
  final payload = {
    'email': email,
    'password': password,
    'returnSecureToken': true,
  };
  final signInUrl = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
  );
  final existingUser = await _postRequest(signInUrl, payload, headers: {});
  if (existingUser != null) {
    return existingUser;
  }
  final signUpUrl = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
  );
  return _postRequest(signUpUrl, payload, headers: {});
}

Future<void> _setDoc({
  required String projectId,
  required String path,
  required Map<String, String> headers,
  required Map<String, dynamic> data,
}) async {
  final url = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$path',
  );
  final payload = encodeFirestoreDoc(data);
  final response = await _patchRequest(url, payload, headers: headers);
  if (response == null) {
    throw StateError('Failed to seed $path');
  }
}

Future<Map<String, dynamic>?> _postRequest(
  Uri uri,
  Map<String, dynamic> body, {
  required Map<String, String> headers,
}) async {
  return _request('POST', uri, body, headers: headers);
}

Future<Map<String, dynamic>?> _patchRequest(
  Uri uri,
  Map<String, dynamic> body, {
  required Map<String, String> headers,
}) async {
  return _request('PATCH', uri, body, headers: headers);
}

Future<Map<String, dynamic>?> _request(
  String method,
  Uri uri,
  Map<String, dynamic> body, {
  required Map<String, String> headers,
}) async {
  final client = HttpClient();
  try {
    final request = switch (method) {
      'PATCH' => await client.patchUrl(uri),
      _ => await client.postUrl(uri),
    };
    headers.forEach(request.headers.set);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('HTTP Error ${response.statusCode}: $responseBody');
      return null;
    }
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

Map<String, dynamic> encodeFirestoreValue(dynamic value) {
  if (value is String) return {'stringValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  if (value is bool) return {'booleanValue': value};
  if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  }
  if (value is List) {
    return {
      'arrayValue': {'values': value.map(encodeFirestoreValue).toList()},
    };
  }
  if (value is Map) {
    return {
      'mapValue': {
        'fields': value.map(
          (key, val) => MapEntry(key as String, encodeFirestoreValue(val)),
        ),
      },
    };
  }
  return {'nullValue': null};
}

Map<String, dynamic> encodeFirestoreDoc(Map<String, dynamic> map) {
  return {
    'fields': map.map((key, val) => MapEntry(key, encodeFirestoreValue(val))),
  };
}

class _FirebaseConfig {
  final String apiKey;
  final String projectId;

  const _FirebaseConfig({required this.apiKey, required this.projectId});
}
