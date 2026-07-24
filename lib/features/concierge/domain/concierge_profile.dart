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

  factory ConciergeProfile.fallback([String id = 'concierge-elena']) {
    return ConciergeProfile(
      id: id,
      name: 'Elena',
      role: 'Senior Travel Specialist',
      specialty: 'Luxury Safaris & Lodges',
      languages: 'English, Spanish, French',
      photoUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400',
      isOnline: true,
    );
  }
}
