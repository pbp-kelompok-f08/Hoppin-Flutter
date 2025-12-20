import 'dart:convert'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter_hoppin/userprofile/models/user_profile.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';

class ProfileService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Get own profile
  static Future<UserProfile> getOwnProfile(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/accounts/profile-detail/');
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  // Get public profile
  static Future<UserProfile> getPublicProfile(
    CookieRequest request,
    String username,
  ) async {
    try {
      final response = await request.get(
        '$baseUrl/accounts/profile/$username/json/',
      );
      
      if (response['success'] == true) {
        return UserProfile.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'User not found');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
    CookieRequest request, {
    required String email,
    required String bio,
    String? favoriteSport,
    String? skillLevel,
  }) async {
    try {
      final response = await request.postJson(
        '$baseUrl/accounts/profile/update-flutter/',
        jsonEncode({  
          'email': email,
          'bio': bio,
          'favorite_sport': favoriteSport ?? '',
          'skill_level': skillLevel ?? '',
        }),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete account
  static Future<Map<String, dynamic>> deleteAccount(
    CookieRequest request,
    String password,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/accounts/delete-account/',
        jsonEncode({'password': password}),  
      );
      return response;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Get user threads
  static Future<List<ThreadModel>> getUserThreads(
    CookieRequest request,
    String username,
  ) async {
    try {
      final response = await request.get(
        '$baseUrl/threads/json/user/$username/',
      );
      
      if (response is List) {
        return response.map((json) => ThreadModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load threads: $e');
    }
  }
}