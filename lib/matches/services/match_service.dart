import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/match_model.dart';

class MatchService {
  final CookieRequest request;

  MatchService(this.request);

  /// ===== GET MATCHES =====
  Future<MatchResponse> fetchMatches({
  String keyword = "",
  String sport = "",
  String when = "",
  }) async {
  try {
    final params = <String, String>{};

    if (keyword.isNotEmpty) params["keyword"] = keyword;
    if (sport.isNotEmpty) params["sport"] = sport;
    if (when.isNotEmpty) params["when"] = when;

    final uri = Uri.https(
      "dion-wisdom-hoppin.pbp.cs.ui.ac.id",
      "/matches/json/",
      params,
    );

    final response = await request.get(uri.toString());

    // Check if response is null
    if (response == null) {
      throw Exception('Server returned null response');
    }

    // Check if response is a String (HTML/error) instead of Map (JSON)
    if (response is String) {
      if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
        throw Exception('Server returned HTML error page instead of JSON.\n\nPlease check:\n1. Is the Django server running on https://m-naufal41-hoppin.pbp.cs.ui.ac.id?\n2. Does the endpoint /matches/json/ exist?\n3. Are you logged in?\n\nError response preview: ${response.substring(0, response.length > 300 ? 300 : response.length)}');
  }
      // If it's a string but not HTML, try to decode it
      final decoded = json.decode(response) as Map<String, dynamic>;
      return MatchResponse.fromJson(decoded);
    }

    // Response should be a Map<String, dynamic>
    if (response is! Map<String, dynamic>) {
      throw Exception('Unexpected response type: ${response.runtimeType}');
    }

    return MatchResponse.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    if (e.toString().contains('<!Doctype') || 
        e.toString().contains('<!DOCTYPE') ||
        e.toString().contains('Unexpected token')) {
      throw Exception('JSON parsing error - Server returned HTML instead of JSON.\n\nPlease check:\n1. Is the Django server running on https://m-naufal41-hoppin.pbp.cs.ui.ac.id?\n2. Does the endpoint /matches/json/ exist?\n3. Are you logged in?\n4. Verify the endpoint returns JSON, not HTML\n\nOriginal error: $e');
  }
    rethrow;
  }
}


  /// ===== CREATE MATCH =====
  Future<bool> createMatch({
    required String title,
    required String category,
    required String location,
    required int maxMembers,
    required String eventDate,
    required String description,
  }) async {
    try {
      final response = await request.postJson(
      "https://dion-wisdom-hoppin.pbp.cs.ui.ac.id/matches/create/",
        jsonEncode({
          "title": title,
          "category": category, // Category name (primary key of SportCategory)
          "location": location,
          "max_members": maxMembers,
          "event_date": eventDate, // Format: "YYYY-MM-DDTHH:MM"
          "description": description,
        }),
    );

      if (response is Map<String, dynamic>) {
        return response["success"] == true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// ===== JOIN MATCH =====
  Future<bool> joinMatch(String matchId) async {
    final response =
        await request.post("https://dion-wisdom-hoppin.pbp.cs.ui.ac.id/matches/$matchId/book/", {});

    if (response is Map<String, dynamic>) {
      return response["success"] == true;
    }
    return false;
  }
}
