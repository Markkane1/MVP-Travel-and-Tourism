// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Starting Firestore Seeding Script (Native Client)...');

  // 1. Read Project Configuration from generated Firebase options
  final configFile = File('lib/firebase_options.dart');
  if (!await configFile.exists()) {
    print('Error: lib/firebase_options.dart does not exist.');
    print('Please run flutterfire configure first.');
    return;
  }

  final content = await configFile.readAsString();
  final apiKeyMatch = RegExp(r"apiKey:\s*'([^']+)'").firstMatch(content);
  final projectIdMatch = RegExp(r"projectId:\s*'([^']+)'").firstMatch(content);

  if (apiKeyMatch == null || projectIdMatch == null) {
    print('Error: Could not parse apiKey or projectId from dev options file.');
    return;
  }

  final apiKey = apiKeyMatch.group(1)!;
  final projectId = projectIdMatch.group(1)!;

  print('Detected Project ID: $projectId');

  final seedEmail = Platform.environment['SEED_EMAIL'];
  final seedPassword = Platform.environment['SEED_PASSWORD'];

  String? idToken;
  try {
    Map<String, dynamic>? response;
    if ((seedEmail?.isNotEmpty ?? false) &&
        (seedPassword?.isNotEmpty ?? false)) {
      print('Signing in with demo user $seedEmail...');
      response = await _authenticateEmailUser(
        apiKey: apiKey,
        email: seedEmail!,
        password: seedPassword!,
      );
    } else {
      print('Signing in anonymously to acquire client auth tokens...');
      final authUrl = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      );
      response = await _postRequest(authUrl, {}, headers: {});
    }

    if (response == null) {
      throw Exception('Failed to acquire auth token.');
    }
    idToken = response['idToken'] as String?;
    print('Signed in successfully! Local UID: ${response['localId']}');
  } catch (e) {
    print('Authentication warning: $e');
    print(
      'Proceeding with unauthenticated requests (seeding might fail if rules enforce auth).',
    );
  }

  final headers = <String, String>{};
  if (idToken != null) {
    headers['Authorization'] = 'Bearer $idToken';
  }

  // 3. Define Seed Data (including latitude and longitude)
  final sampleTours = [
    {
      'id': 'paris-getaway',
      'title': 'Paris Getaway',
      'destination': 'Paris, France',
      'category': 'City',
      'badges': ['Featured', 'Popular'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=800',
        'https://images.unsplash.com/photo-1499856871958-5b9647a64060?q=80&w=800',
      ],
      'pricePerPerson': 1200.0,
      'currency': 'USD',
      'durationDays': 7,
      'maxParticipants': 16,
      'ratingAverage': 4.9,
      'ratingCount': 120,
      'overview':
          'Experience the romantic history, fine art, and culinary excellence of Paris. Explore the Louvre, Eiffel Tower, and charming sidewalk bistros.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Arrival & Seine Cruise',
          'description':
              'Check in to your boutique hotel, then enjoy a scenic cruise down the Seine river.',
        },
        {
          'day': 2,
          'title': 'Louvre Museum Tour',
          'description':
              'Skip the line for a private guided walk through the world\'s largest art museum.',
        },
      ],
      'inclusions': [
        'Boutique hotel stay',
        'Daily breakfast',
        'Seine river cruise',
        'Private museum guides',
      ],
      'latitude': 48.8566,
      'longitude': 2.3522,
      'reviews': [
        {
          'userName': 'James Wilson',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150',
          'overallRating': 5.0,
          'comment':
              'An absolutely breathtaking trip! The service was immaculate and the views were out of this world.',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
      ],
    },
    {
      'id': 'serengeti-safari',
      'title': 'Serengeti Private Expedition',
      'destination': 'Serengeti, Tanzania',
      'category': 'Adventure',
      'badges': ['Featured', 'Top Rated'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=800',
        'https://images.unsplash.com/photo-1523805009345-7448845a9e53?q=80&w=800',
      ],
      'pricePerPerson': 3500.0,
      'currency': 'USD',
      'durationDays': 10,
      'maxParticipants': 8,
      'ratingAverage': 4.8,
      'ratingCount': 85,
      'overview':
          'Witness the majestic wildlife migration on this premium private safari package. Includes luxury lodges and highly experienced wildlife track guides.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Kilimanjaro Arrival',
          'description':
              'Arrive in Tanzania and check in to your safari briefing lodge.',
        },
        {
          'day': 2,
          'title': 'Game Drive & Wilderness Camp',
          'description': 'Begin tracking lions, leopards, and elephant herds.',
        },
      ],
      'inclusions': [
        'Luxury lodge accommodation',
        'All meals included',
        'Private 4x4 game vehicles',
        'National park entry passes',
      ],
      'latitude': -2.1540,
      'longitude': 34.6857,
      'reviews': [
        {
          'userName': 'Emily Davis',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
          'overallRating': 4.8,
          'comment':
              'Seeing the Great Migration up close was a life-changing experience. Highly recommend this tour.',
          'createdAt': DateTime.now().subtract(const Duration(days: 4)),
        },
      ],
    },
    {
      'id': 'overwater-villas',
      'title': 'Overwater Villa Experience',
      'destination': 'Bora Bora, French Polynesia',
      'category': 'Beach',
      'badges': ['Featured', 'Luxury', 'Exclusive'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=800',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800',
      ],
      'pricePerPerson': 4800.0,
      'currency': 'USD',
      'durationDays': 5,
      'maxParticipants': 4,
      'ratingAverage': 4.9,
      'ratingCount': 210,
      'overview':
          'Escape to your private overwater bungalow. Swim in turquoise lagoons, indulge in couples spa treatments, and enjoy candlelight dinners on private sandbanks.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Lagoon Arrival',
          'description':
              'Check into your overwater villa and unwind with a sunset cruise.',
        },
        {
          'day': 2,
          'title': 'Spa & Sandbank',
          'description':
              'Enjoy a spa session and private candlelight dinner on the sandbank.',
        },
      ],
      'inclusions': [
        'Overwater villa accommodation',
        'All-inclusive premium dining',
        'Spa credit',
        'Private catamaran charter',
      ],
      'latitude': -16.5004,
      'longitude': -151.7415,
      'reviews': [
        {
          'userName': 'Arthur Pendragon',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150',
          'overallRating': 5.0,
          'comment':
              'Paradise on Earth. The overwater villas are luxurious and private.',
          'createdAt': DateTime.now().subtract(const Duration(days: 7)),
        },
      ],
    },
    {
      'id': 'island-hopper',
      'title': 'Private Island Hopper',
      'destination': 'Fiji Islands',
      'category': 'Beach',
      'badges': ['Popular', 'Luxury'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800',
      ],
      'pricePerPerson': 6200.0,
      'currency': 'USD',
      'durationDays': 8,
      'maxParticipants': 6,
      'ratingAverage': 4.7,
      'ratingCount': 45,
      'overview':
          'Sail between the outer Yasawa islands on a luxury motor yacht. Snorkel pristine reefs and picnic on untouched coral keys.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Yacht Welcome',
          'description':
              'Board your private yacht and cruise toward the Yasawa chain.',
        },
        {
          'day': 2,
          'title': 'Reefs & Keys',
          'description':
              'Snorkel vibrant reefs and enjoy a chef-prepared beach picnic.',
        },
      ],
      'inclusions': [
        'Private yacht cabins',
        'Chef service on board',
        'Snorkeling equipment',
        'Custom island tours',
      ],
      'latitude': -17.7134,
      'longitude': 178.0650,
      'reviews': [
        {
          'userName': 'Sarah Jenkins',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150',
          'overallRating': 4.7,
          'comment':
              'Amazing reefs, incredible staff, and complete serenity. A perfect getaway.',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        },
      ],
    },
    {
      'id': 'azure-sandbank',
      'title': 'Azure Sandbank Retreat',
      'destination': 'Zanzibar, Tanzania',
      'category': 'Beach',
      'badges': ['Exclusive', 'Trending'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=800',
      ],
      'pricePerPerson': 2400.0,
      'currency': 'USD',
      'durationDays': 6,
      'maxParticipants': 12,
      'ratingAverage': 4.9,
      'ratingCount': 110,
      'overview':
          'Relax on the sugar-white sandbanks of Zanzibar. Swim alongside wild dolphins and experience sunset dhow cruises with fresh seafood.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Beachfront Check-in',
          'description':
              'Arrive at the resort and settle in for a relaxed evening by the sea.',
        },
        {
          'day': 2,
          'title': 'Dhow & Dolphin Day',
          'description':
              'Cruise at sunset and join a guided dolphin-watching outing.',
        },
      ],
      'inclusions': [
        'Boutique beachfront resort',
        'Seafood dinners',
        'Dolphin cruise',
        'Local spice tour',
      ],
      'latitude': -6.1659,
      'longitude': 39.2026,
      'reviews': [
        {
          'userName': 'Michael Chang',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=150',
          'overallRating': 5.0,
          'comment':
              'Unbelievable sandbanks, turquoise waters, and fresh local fruits. Paradise!',
          'createdAt': DateTime.now().subtract(const Duration(days: 12)),
        },
      ],
    },
    {
      'id': 'maldives-retreat',
      'title': 'Maldives Luxury Retreat',
      'destination': 'Maldives',
      'category': 'Beach',
      'badges': ['Featured', 'Luxury'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=800',
      ],
      'pricePerPerson': 5500.0,
      'currency': 'USD',
      'durationDays': 7,
      'maxParticipants': 8,
      'ratingAverage': 4.9,
      'ratingCount': 340,
      'overview':
          'Soak up the sun on private villa terraces. Includes glass-bottom lounges, premium scuba dives, and sunset massage treatments.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Villa Arrival',
          'description':
              'Check in to your luxury villa and enjoy a champagne sunset welcome.',
        },
        {
          'day': 2,
          'title': 'Dive & Unwind',
          'description':
              'Explore reef life with a private guide, then relax with a sunset massage.',
        },
      ],
      'inclusions': [
        'Glass bottom villa stays',
        'Private scuba guide',
        'Couples massage session',
        'Champagne breakfast',
      ],
      'latitude': 3.2028,
      'longitude': 73.2207,
      'reviews': [
        {
          'userName': 'Sophia Lauren',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150',
          'overallRating': 4.9,
          'comment':
              'Stunning beaches, luxurious amenities, and amazing marine life. Loved the overwater spa.',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
      ],
    },
    {
      'id': 'swiss-alpine',
      'title': 'Swiss Alpine Expedition',
      'destination': 'Zermatt, Switzerland',
      'category': 'Mountain',
      'badges': ['Top Rated', 'Adventure'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=800',
      ],
      'pricePerPerson': 3200.0,
      'currency': 'USD',
      'durationDays': 8,
      'maxParticipants': 10,
      'ratingAverage': 4.8,
      'ratingCount': 72,
      'overview':
          'Hike and ski under the mighty Matterhorn. Rest in cozy luxury ski lodges, warm up with traditional cheese fondue, and travel on panoramic high-altitude trains.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Matterhorn Arrival',
          'description':
              'Arrive in Zermatt and settle into your chalet with alpine views.',
        },
        {
          'day': 2,
          'title': 'Glacier Adventure',
          'description':
              'Spend the day hiking or skiing, then return for fondue by the fire.',
        },
      ],
      'inclusions': [
        'Luxury ski lodge chalet',
        'Ski lift passes',
        'Daily gourmet dinners',
        'Glacier Express train ticket',
      ],
      'latitude': 46.0207,
      'longitude': 7.7491,
      'reviews': [
        {
          'userName': 'Hans Mueller',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=150',
          'overallRating': 4.8,
          'comment':
              'Breath-taking vistas of the Matterhorn. The Chalets are warm and cozy after a long hike.',
          'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        },
      ],
    },
    {
      'id': 'kyoto-walk',
      'title': 'Kyoto Heritage Walk',
      'destination': 'Kyoto, Japan',
      'category': 'City',
      'badges': ['Top Rated', 'Wellness'],
      'heroImageUrl':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800',
      'galleryImageUrls': [
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800',
      ],
      'pricePerPerson': 1800.0,
      'currency': 'USD',
      'durationDays': 6,
      'maxParticipants': 12,
      'ratingAverage': 4.9,
      'ratingCount': 195,
      'overview':
          'Immerse yourself in Zen gardens, bamboo groves, and ancient tea ceremonies. Tour stunning shrines and rest at traditional hot-spring ryokans.',
      'itinerary': [
        {
          'day': 1,
          'title': 'Temple Arrival',
          'description':
              'Arrive in Kyoto and begin with an evening stroll through Gion.',
        },
        {
          'day': 2,
          'title': 'Tea & Shrines',
          'description':
              'Visit bamboo groves, shrines, and end with a private tea ceremony.',
        },
      ],
      'inclusions': [
        'Traditional Ryokan stay',
        'Kaiseki dinners',
        'Private tea master',
        'Hot spring (onsen) access',
      ],
      'latitude': 35.0116,
      'longitude': 135.7681,
      'reviews': [
        {
          'userName': 'Kenji Sato',
          'userPhotoUrl':
              'https://images.unsplash.com/photo-1542206395-9feb3edaa68d?q=80&w=150',
          'overallRating': 5.0,
          'comment':
              'A serene journey through time. The Kaiseki dining was outstanding.',
          'createdAt': DateTime.now().subtract(const Duration(days: 18)),
        },
      ],
    },
  ];

  // 4. Seeding Loop
  print('Seeding database collections...');
  for (final tour in sampleTours) {
    final tourId = tour['id'] as String;
    final reviews = tour.remove('reviews') as List;

    // Inject Prompt 8 fields dynamically
    final now = DateTime.now();
    tour['availableDates'] = [
      DateTime(now.year, now.month, now.day + 2),
      DateTime(now.year, now.month, now.day + 5),
      DateTime(now.year, now.month, now.day + 8),
      DateTime(now.year, now.month, now.day + 12),
      DateTime(now.year, now.month, now.day + 15),
      DateTime(now.year, now.month, now.day + 19),
      DateTime(now.year, now.month, now.day + 22),
      DateTime(now.year, now.month, now.day + 26),
    ];
    tour['privateVehicleSurcharge'] = 250.0;
    tour['groupSizeOptions'] = [
      {'label': 'Shared', 'maxSize': 16, 'priceModifier': 0.0},
      {'label': 'Max 6', 'maxSize': 6, 'priceModifier': 500.0},
      {'label': 'Max 12', 'maxSize': 12, 'priceModifier': 300.0},
    ];

    print('Uploading tour: $tourId...');
    final docUrl = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/tours?documentId=$tourId',
    );

    final payload = encodeFirestoreDoc(tour);
    final response = await _postRequest(docUrl, payload, headers: headers);

    if (response == null) {
      print('Failed to upload tour $tourId.');
      print(
        'Check security rules or ensure allow write is temporarily enabled.',
      );
      continue;
    }

    print('Successfully uploaded tour $tourId! Seeding reviews...');

    // Seed subcollection reviews
    for (var i = 0; i < reviews.length; i++) {
      final review = reviews[i] as Map<String, dynamic>;
      review['bookingId'] = 'seed-booking-$tourId-${i + 1}';
      review['userId'] = 'seed-user-${i + 1}';
      review['aspectRatings'] = {
        'service': review['overallRating'],
        'accommodation': review['overallRating'],
        'activities': review['overallRating'],
        'value': review['overallRating'],
      };
      review['photoUrls'] = <String>[];
      final reviewId = 'review-${i + 1}';
      final reviewUrl = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/tours/$tourId/reviews?documentId=$reviewId',
      );

      final reviewPayload = encodeFirestoreDoc(review);
      final rResponse = await _postRequest(
        reviewUrl,
        reviewPayload,
        headers: headers,
      );
      if (rResponse == null) {
        print('Failed to upload review $reviewId for $tourId.');
      }
    }
  }

  print('Database Seeding Complete!');
}

Future<Map<String, dynamic>?> _authenticateEmailUser({
  required String apiKey,
  required String email,
  required String password,
}) async {
  final signInUrl = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
  );
  final payload = {
    'email': email,
    'password': password,
    'returnSecureToken': true,
  };

  final existingUser = await _postRequest(signInUrl, payload, headers: {});
  if (existingUser != null) {
    return existingUser;
  }

  final signUpUrl = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
  );
  return _postRequest(signUpUrl, payload, headers: {});
}

Future<Map<String, dynamic>?> _postRequest(
  Uri uri,
  Map<String, dynamic> body, {
  required Map<String, String> headers,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();

    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      print('HTTP Error ${response.statusCode}: $responseBody');
      return null;
    }
    return jsonDecode(responseBody) as Map<String, dynamic>;
  } catch (e) {
    print('HTTP Request Exception: $e');
    return null;
  } finally {
    client.close();
  }
}

Map<String, dynamic> encodeFirestoreValue(dynamic value) {
  if (value is String) {
    return {'stringValue': value};
  } else if (value is int) {
    return {'integerValue': value.toString()};
  } else if (value is double) {
    return {'doubleValue': value};
  } else if (value is bool) {
    return {'booleanValue': value};
  } else if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  } else if (value is List) {
    return {
      'arrayValue': {
        'values': value.map((item) => encodeFirestoreValue(item)).toList(),
      },
    };
  } else if (value is Map) {
    return {
      'mapValue': {
        'fields': value.map(
          (key, val) => MapEntry(key as String, encodeFirestoreValue(val)),
        ),
      },
    };
  } else if (value == null) {
    return {'nullValue': null};
  }
  throw UnsupportedError('Unsupported type: ${value.runtimeType}');
}

Map<String, dynamic> encodeFirestoreDoc(Map<String, dynamic> map) {
  return {
    'fields': map.map((key, val) => MapEntry(key, encodeFirestoreValue(val))),
  };
}
