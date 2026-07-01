import 'package:cloud_firestore/cloud_firestore.dart';

/// Representation model of a concierge agent.
class ConciergeProfile {
  final String id;
  final String name;
  final String role;
  final String specialty;
  final String languages;
  final String photoUrl;
  final bool isOnline;

  const ConciergeProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    required this.languages,
    required this.photoUrl,
    required this.isOnline,
  });

  factory ConciergeProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConciergeProfile(
      id: doc.id,
      name: data['name'] ?? 'Elena',
      role: data['role'] ?? 'Senior Travel Specialist',
      specialty: data['specialty'] ?? 'Luxury Safaris & Lodges',
      languages: data['languages'] ?? 'English, Spanish, French',
      photoUrl: data['photoUrl'] ?? '',
      isOnline: data['isOnline'] ?? true,
    );
  }
}
