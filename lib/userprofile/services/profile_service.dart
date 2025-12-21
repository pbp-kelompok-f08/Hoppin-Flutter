import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter_hoppin/userprofile/models/user_profile.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';

class ProfileService {
  static const String baseUrl = 'https://dion-wisdom-hoppin.pbp.cs.ui.ac.id';

  static Future<UserProfile> getOwnProfile(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/accounts/profile-detail/');
      
      // Check if response is a String (HTML/error) instead of Map (JSON)
      if (response is String) {
        if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server returned HTML error page instead of JSON.\n\nPlease check:\n1. Is the Django server running on $baseUrl?\n2. Are you logged in?\n3. Does the endpoint /accounts/profile-detail/ exist?\n\nError response preview: ${response.substring(0, response.length > 300 ? 300 : response.length)}');
        }
        // If it's a string but not HTML, try to decode it
        final decoded = json.decode(response) as Map<String, dynamic>;
        return UserProfile.fromJson(decoded);
      }
      
      // Response should be a Map<String, dynamic>
      return UserProfile.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('<!Doctype') || 
          e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('Unexpected token')) {
        throw Exception('JSON parsing error - Server returned HTML instead of JSON.\n\nPlease check:\n1. Is the Django server running on $baseUrl?\n2. Are you logged in?\n3. Verify the endpoint returns JSON, not HTML\n\nOriginal error: $e');
      }
      throw Exception('Failed to load profile: $e');
    }
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
      final response = await request.get(
        '$baseUrl/threads/json/user/$username/',
      );
      
      // Check if response is a String (HTML/error) instead of List (JSON)
      if (response is String) {
        if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
          // Endpoint might not exist, return empty list gracefully
          return [];
        }
        // If it's a string but not HTML, try to decode it
        final decoded = json.decode(response);
        if (decoded is List) {
          return decoded.map((json) => ThreadModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      }
      
      if (response is List) {
        return response.map((json) => ThreadModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist, return empty list gracefully
      if (e.toString().contains('<!Doctype') || 
          e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('Unexpected token')) {
        return [];
      }
      // For other errors, still return empty list to prevent UI crash
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
