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

    return MatchResponse.fromJson(response);
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
