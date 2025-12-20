import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/match_model.dart';

class MatchService {
  final CookieRequest request;

  MatchService(this.request);

  Future<MatchResponse> fetchMatches({
    String? keyword,
    String? sport,
    String? when,
  }) async {
    try {
      final params = <String, String>{};

      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
      if (sport != null && sport.isNotEmpty) params['sport'] = sport;
      if (when != null && when.isNotEmpty) params['when'] = when;

      // Build URL dengan query
      final uri = Uri.http(
        "127.0.0.1:8000",
        "/matches/json/",
        params,
      );

      final response = await request.get(uri.toString());

      // Check if response is a String (HTML/error) instead of Map (JSON)
      if (response is String) {
        if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server returned HTML error page instead of JSON.\n\nPlease check:\n1. Is the Django server running on http://127.0.0.1:8000?\n2. Does the endpoint /matches/json/ exist?\n3. Check your Django URLs configuration.\n\nError response preview: ${response.substring(0, response.length > 300 ? 300 : response.length)}');
        }
        // If it's a string but not HTML, try to decode it
        return MatchResponse.fromJson(json.decode(response) as Map<String, dynamic>);
      }

      // Response should be a Map<String, dynamic>
      return MatchResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('<!Doctype') || 
          e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('Unexpected token')) {
        throw Exception('JSON parsing error - Server returned HTML instead of JSON.\n\nPlease check:\n1. Is the Django server running on http://127.0.0.1:8000?\n2. Does the endpoint /matches/json/ exist?\n3. Verify the endpoint returns JSON, not HTML\n\nOriginal error: $e');
      }
      rethrow;
    }
  }


  Future<bool> joinMatch(String matchId) async {
    final response = await request.post(
      "http://127.0.0.1:8000/matches/$matchId/book/",
      {},
    );
    return response['success'] == true;
  }

  Future<bool> createMatch({
    required String title,
    required String category,
    required String location,
    required int maxMembers,
    required String eventDate,
    required String description,
  }) async {
    final response = await request.post(
      "http://127.0.0.1:8000/matches/create/",
      {
        'title': title,
        'category': category,
        'location': location,
        'max_members': maxMembers.toString(),
        'event_date': eventDate,
        'description': description,
      },
    );

    return response['success'] == true;
  }
}
