class UserProfile {
  final String username;
  final String email;
  final String? bio;
  final String? profilePicture;
  final String? favoriteSport;
  final String? skillLevel;
  final String dateJoined;
  final bool isOwnProfile;

  static const String _baseUrl = 'http://127.0.0.1:8000';

  UserProfile({
    required this.username,
    required this.email,
    this.bio,
    this.profilePicture,
    this.favoriteSport,
    this.skillLevel,
    required this.dateJoined,
    this.isOwnProfile = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle both formats: direct data or nested in "data" key
    final data = json['data'] ?? json;
    
    return UserProfile(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'],
      profilePicture: data['profile_picture'],
      favoriteSport: data['favorite_sport'],
      skillLevel: data['skill_level'],
      dateJoined: data['date_joined'] ?? '',
      isOwnProfile: data['is_own_profile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'bio': bio,
      'favorite_sport': favoriteSport,
      'skill_level': skillLevel,
    };
  }

  // Helper to format date
  String getFormattedDate() {
    try {
      final date = DateTime.parse(dateJoined);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Member since ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Member since $dateJoined';
    }
  }

  // Helper to get full profile picture URL
  String? get profilePictureUrl {
    if (profilePicture == null || profilePicture!.isEmpty) return null;
    if (profilePicture!.startsWith('http')) return profilePicture;
    return '$_baseUrl$profilePicture';
  }
}