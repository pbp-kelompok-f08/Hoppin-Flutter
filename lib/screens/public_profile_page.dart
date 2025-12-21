import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hoppin/userprofile/models/user_profile.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';
import 'package:flutter_hoppin/userprofile/services/profile_service.dart';
import 'package:flutter_hoppin/userprofile/widgets/thread_card.dart';

class PublicProfilePage extends StatefulWidget {
  final String username;

  const PublicProfilePage({
    super.key,
    required this.username,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  late Future<UserProfile> _profileFuture;
  late Future<List<ThreadModel>> _threadsFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _profileFuture = ProfileService.getPublicProfile(request, widget.username);
    _threadsFuture = ProfileService.getUserThreads(request, widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('@${widget.username}'),
        elevation: 0,
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header (tanpa Edit button)
                _buildProfileHeader(profile),
                const SizedBox(height: 16),

                // Profile Info
                _buildProfileInfo(profile),
                const SizedBox(height: 16),

                // Threads Section
                _buildThreadsSection(profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: profile.profilePicture != null
                ? NetworkImage(profile.profilePicture!)
                : null,  
            backgroundColor: Colors.grey[800],
            child: profile.profilePicture == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)  
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${profile.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.getFormattedDate(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('BIO', profile.bio ?? 'Belum ada bio.',
              isItalic: profile.bio == null),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem('EMAIL', profile.email)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildInfoItem(
                      'FAVORITE SPORT', profile.favoriteSport ?? '-')),
            ],
          ),
          const SizedBox(height: 16),
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

  Widget _buildThreadsSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${profile.username}\'s Threads',
            style: const TextStyle(
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