import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter_hoppin/userprofile/models/user_profile.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';

class ProfileService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<UserProfile> getOwnProfile(CookieRequest request) async {
    final response = await request.get('$baseUrl/accounts/profile-detail/');
    return UserProfile.fromJson(response);
  }

  static Future<UserProfile> getPublicProfile(
    CookieRequest request,
    String username,
  ) async {
    final response =
        await request.get('$baseUrl/accounts/profile/$username/json/');
    return UserProfile.fromJson(response['data']);
  }

  static Future<Map<String, dynamic>> updateProfile(
    CookieRequest request, {
    required String email,
    required String bio,
    String? favoriteSport,
    String? skillLevel,
  }) async {
    return await request.postJson(
      '$baseUrl/accounts/profile/update-flutter/',
      jsonEncode({
        'email': email,
        'bio': bio,
        'favorite_sport': favoriteSport ?? '',
        'skill_level': skillLevel ?? '',
      }),
    );
  }

  static Future<Map<String, dynamic>> deleteAccount(
    CookieRequest request,
    String password,
  ) async {
    return await request.postJson(
      '$baseUrl/accounts/delete-account/',
      jsonEncode({'password': password}),
    );
  }

  static Future<List<ThreadModel>> getUserThreads(
    CookieRequest request,
    String username,
  ) async {
    try {
      final response =
          await request.get('$baseUrl/threads/json/user/$username/');
      return (response as List)
          .map((e) => ThreadModel.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> removeProfilePicture(
    CookieRequest request,
  ) async {
    return await request.post(
      '$baseUrl/accounts/profile/remove-picture/',
      {},
    );
  }
}
