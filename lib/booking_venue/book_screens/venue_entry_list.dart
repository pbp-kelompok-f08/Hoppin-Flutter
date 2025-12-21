import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/venue_model.dart';
import '../book_widgets/venue_card.dart';
import 'venue_detail.dart';
import 'my_bookings.dart';

class VenueEntryListPage extends StatefulWidget {
  const VenueEntryListPage({super.key});

  @override
  State<VenueEntryListPage> createState() => _VenueEntryListPageState();
}

class _VenueEntryListPageState extends State<VenueEntryListPage> {
  late Future<VenueModel> futureVenues;
  String selectedAlphabet = "";

  @override
  void initState() {
    super.initState();
    futureVenues = fetchVenues(context.read<CookieRequest>());
  }

  Future<VenueModel> fetchVenues(CookieRequest request, {String? alphabet}) async {
    try {
      if (alphabet != null && alphabet.isNotEmpty && alphabet != "") {
        // Use filter endpoint when alphabet is specified and not empty
        final uri = Uri.https(
          "dion-wisdom-hoppin.pbp.cs.ui.ac.id",
          "/booking-venue/filter-venues-api/",
          {'alphabet': alphabet},
        );
        final response = await request.get(uri.toString());

        // Handle different response formats
        if (response is List) {
          // If response is a list, wrap it in the expected format
          return VenueModel.fromJson({"venues": response});
        } else {
          // If response is already the expected map format
          return VenueModel.fromJson(response);
        }
      } else {
        // Use regular endpoint when no filter
        final uri = Uri.https(
          "dion-wisdom-hoppin.pbp.cs.ui.ac.id",
          "/booking-venue/show-venue-json/",
        );
        final response = await request.get(uri.toString());
        return VenueModel.fromJson(response);
      }
    } catch (e) {
      // If JSON parsing fails (likely due to HTML response), show error
      if (!mounted) rethrow;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading venues: $e")),
      );
      // Return empty venue list on error
      return VenueModel(venues: []);
    }
  }

  void _applyFilters() {
    setState(() {
      futureVenues = fetchVenues(context.read<CookieRequest>(), alphabet: selectedAlphabet);
    });
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.book_online, color: Colors.white),
            tooltip: "My Bookings",
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter Venues",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Filter by Alphabet",
                            style: TextStyle(
                              color: Color(0xFFCFCFCF),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2A2A2A)),
                            ),
                            child: DropdownButton<String>(
                              value: selectedAlphabet.isEmpty ? "" : selectedAlphabet,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: "",
                                  child: Text(
                                    "All Letters",
                                    style: TextStyle(color: Color(0xFFEAEAEA)),
                                  ),
                                ),
                                ...'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
                                  return DropdownMenuItem<String>(
                                    value: letter,
                                    child: Text(
                                      letter,
                                      style: const TextStyle(color: Color(0xFFEAEAEA)),
                                    ),
                                  );
                                }),
                                const DropdownMenuItem<String>(
                                  value: "other",
                                  child: Text(
                                    "Other",
                                    style: TextStyle(color: Color(0xFFEAEAEA)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedAlphabet = value ?? "";
                                });
                              },
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1C1C1C),
                              underline: const SizedBox.shrink(),
                              hint: const Text(
                                "All Letters",
                                style: TextStyle(color: Color(0xFFCFCFCF)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: const Color(0xFFEAEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: const Row(
                        children: [
                          Text("🔍"),
                          SizedBox(width: 8),
                          Text("Apply Filters"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Venue List
          Expanded(
            child: FutureBuilder<VenueModel>(
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
          ),
        ],
      ),
    );
  }
}
