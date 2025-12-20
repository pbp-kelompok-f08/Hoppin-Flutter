import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/venue_model.dart';
import '../book_widgets/venue_card.dart';
import 'venue_detail.dart';

class VenueEntryListPage extends StatefulWidget {
  const VenueEntryListPage({super.key});

  @override
  State<VenueEntryListPage> createState() => _VenueEntryListPageState();
}

class _VenueEntryListPageState extends State<VenueEntryListPage> {
  late Future<VenueModel> futureVenues;

  @override
  void initState() {
    super.initState();
    futureVenues = fetchVenues(context.read<CookieRequest>());
  }

  Future<VenueModel> fetchVenues(CookieRequest request) async {
    try {
      const url = 'http://127.0.0.1:8000/booking-venue/show-venue-json/';
      final response = await request.get(url);
      
      // Check if response is a String (HTML/error) instead of Map (JSON)
      if (response is String) {
        if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server returned HTML error page instead of JSON.\n\nPlease check:\n1. Is the Django server running on http://127.0.0.1:8000?\n2. Does the endpoint /booking-venue/show-venue-json/ exist?\n3. Check your Django URLs configuration.\n\nError response preview: ${response.substring(0, response.length > 300 ? 300 : response.length)}');
        }
        // If it's a string but not HTML, try to decode it
        return VenueModel.fromJson(json.decode(response) as Map<String, dynamic>);
      }
      
      // Response should be a Map<String, dynamic>
      return VenueModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('<!Doctype') || 
          e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('Unexpected token')) {
        throw Exception('JSON parsing error - Server returned HTML instead of JSON.\n\nPlease check:\n1. Is the Django server running on http://127.0.0.1:8000?\n2. Does the endpoint /booking-venue/show-venue-json/ exist?\n3. Verify the endpoint returns JSON, not HTML\n\nOriginal error: $e');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      // drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          "Venue List",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<VenueModel>(
        future: futureVenues,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.venues.isEmpty) {
            return const Center(
              child: Text(
                "No venues found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final venues = snapshot.data!.venues;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: venues.length,
            itemBuilder: (_, index) => VenueCard(
              venue: venues[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueDetailPage(
                      venue: venues[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}