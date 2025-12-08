import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';
import '../models/book_model.dart';
import 'venue_entry_list.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final request = context.read<CookieRequest>();
      const url = 'http://127.0.0.1:8000/booking-venue/show-bookings-json/';
      final response = await request.get(url);
      final bookModel = BookModel.fromJson(response);
      if (!mounted) return;
      setState(() {
        bookings = bookModel.bookings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching bookings: $e")),
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/booking-venue/delete-booking/$bookingId/',
        {},
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking cancelled successfully")),
        );
        // Remove from local list immediately
        setState(() {
          bookings.removeWhere((b) => b.id == bookingId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Failed to cancel booking")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            color: const Color(0xFF1C1C1C).withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Bookings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage your venue reservations",
                      style: TextStyle(
                        color: Color(0xFFA1A1A1),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VenueEntryListPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    foregroundColor: const Color(0xFFEAEAEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Row(
                    children: [
                      Text("📋", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text("Book New Venue"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bookings list
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : bookings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "📋",
                              style: TextStyle(fontSize: 64),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No bookings yet",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "You haven't made any venue bookings yet.\nStart exploring available venues and book your first one!",
                              style: TextStyle(
                                color: Color(0xFFA1A1A1),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            // Browse Venues button
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2A2A2A)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "🏟️",
                                          style: TextStyle(fontSize: 32),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking.venue,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Text("📅", style: TextStyle(fontSize: 16)),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${DateFormat('yyyy-MM-dd').format(booking.date)} at ${booking.time}",
                                                style: const TextStyle(
                                                  color: Color(0xFFCFCFCF),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: booking.status == 'confirmed'
                                                  ? const Color(0xFFEAEAEA).withOpacity(0.2)
                                                  : booking.status == 'pending'
                                                      ? const Color(0xFFFFB020).withOpacity(0.2)
                                                      : const Color(0xFFFF6B6B).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: booking.status == 'confirmed'
                                                    ? const Color(0xFFEAEAEA).withOpacity(0.3)
                                                    : booking.status == 'pending'
                                                        ? const Color(0xFFFFB020).withOpacity(0.3)
                                                        : const Color(0xFFFF6B6B).withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              booking.status.toUpperCase(),
                                              style: TextStyle(
                                                color: booking.status == 'confirmed'
                                                    ? const Color(0xFFEAEAEA)
                                                    : booking.status == 'pending'
                                                        ? const Color(0xFFFFB020)
                                                        : const Color(0xFFFF6B6B),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (booking.status == 'pending')
                                  ElevatedButton(
                                    onPressed: () => cancelBooking(booking.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("❌", style: TextStyle(fontSize: 16)),
                                        SizedBox(width: 8),
                                        Text("Cancel"),
                                      ],
                                    ),
                                  ),
                              ],
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