import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const apiKey = 'AIzaSyDM7XFcpCcJ8Hqu006Dvg3Gb2f0j98fHc0';

  final accounts = [
    {'email': 'superadmin@travelmvp.com', 'password': 'SuperAdmin123!'},
    {'email': 'admin@travelmvp.com', 'password': 'admin123'},
  ];

  print('Seeding admin accounts into Firebase Auth...');

  for (final account in accounts) {
    final email = account['email']!;
    final password = account['password']!;

    // 1. Try Sign In
    final signInUrl = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );
    final payload = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    final signInRes = await _postRequest(signInUrl, payload);
    if (signInRes != null && signInRes['localId'] != null) {
      print('✅ Account $email already exists in Firebase Auth (ID: ${signInRes['localId']}).');
      continue;
    }

    // 2. Sign Up if not existing
    final signUpUrl = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    final signUpRes = await _postRequest(signUpUrl, payload);
    if (signUpRes != null && signUpRes['localId'] != null) {
      print('🎉 Successfully created account $email in Firebase Auth (ID: ${signUpRes['localId']}).');
    } else {
      print('❌ Failed to create $email in Firebase Auth.');
    }
  }
}

Future<Map<String, dynamic>?> _postRequest(Uri uri, Map<String, dynamic> body) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      return null;
    }
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
