import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hoppin/userprofile/models/user_profile.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';
import 'package:flutter_hoppin/userprofile/services/profile_service.dart';
import 'package:flutter_hoppin/screens/edit_profile_page.dart';
import 'package:flutter_hoppin/userprofile/widgets/thread_card.dart';
import 'package:flutter_hoppin/screens/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> _profileFuture;
  late Future<List<ThreadModel>> _threadsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final request = context.read<CookieRequest>();

    // Check if user is logged in
    if (!request.loggedIn) {
      // User not logged in, navigate to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return;
    }
    
    setState(() {
      _profileFuture = ProfileService.getOwnProfile(request);
      _threadsFuture = _profileFuture.then((profile) => 
        ProfileService.getUserThreads(request, profile.username)
      );
    });
  }

  Future<void> _handleLogout() async {
    final request = context.read<CookieRequest>();

    try {
      await request.logout("http://localhost:8000/auth/logout/");
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No profile data',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final profile = snapshot.data!;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(profile),
                  const SizedBox(height: 16),

                  // Profile Info Card
                  _buildProfileInfo(profile),
                  const SizedBox(height: 16),

                  // Threads Section
                  _buildThreadsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 48,
            backgroundImage: profile.profilePictureUrl != null
                ? NetworkImage('${profile.profilePictureUrl}?v=${DateTime.now().millisecondsSinceEpoch}',)
                : null,
            backgroundColor: Colors.grey[800],
            child: profile.profilePictureUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.white) 
                : null,
          ),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.getFormattedDate(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(profile: profile),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6E8E6),
                        foregroundColor: const Color(0xFF262626),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(width: 8),

                    OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          _buildInfoItem(
            'BIO',
            profile.bio ?? 'Belum ada bio.',
            isItalic: profile.bio == null,
          ),
          const SizedBox(height: 16),

          // Email and Favorite Sport
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('EMAIL', profile.email),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  'FAVORITE SPORT',
                  profile.favoriteSport ?? '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Skill Level
          _buildInfoItem(
            'SKILL LEVEL',
            profile.skillLevel != null
                ? profile.skillLevel![0].toUpperCase() +
                    profile.skillLevel!.substring(1)
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildThreadsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Threads',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ThreadModel>>(
            future: _threadsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load threads',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              final threads = snapshot.data ?? [];

              if (threads.isEmpty) {
                return Center(
                  child: Text(
                    'No threads yet.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              return Column(
                children: threads.map((thread) => ThreadCard(thread: thread)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}