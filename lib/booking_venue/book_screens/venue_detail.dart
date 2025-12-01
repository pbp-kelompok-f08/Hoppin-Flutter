import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/venue_model.dart';
import '../../screens/login.dart';

class VenueDetailPage extends StatefulWidget {
  final Venue venue;

  const VenueDetailPage({super.key, required this.venue});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int selectedDuration = 1;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEAEAEA),
              onPrimary: Color(0xFF0E0E0E),
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFEAEAEA),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEAEAEA),
              onPrimary: Color(0xFF0E0E0E),
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFEAEAEA),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _submitBooking() async {
    if (selectedDate == null || selectedTime == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    final DateTime bookingDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final now = DateTime.now();
    final twoHoursFromNow = now.add(const Duration(hours: 2));

    if (bookingDateTime.isBefore(twoHoursFromNow)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bookings must be made at least 2 hours in advance")),
      );
      return;
    }

    // Get request before async gap
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/booking-venue/book/${widget.venue.id}/',
        {
          'date': dateFormat.format(selectedDate!),
          'time': '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        },
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking successful!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Booking failed")),
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
    final request = context.watch<CookieRequest>();
    final totalPrice = widget.venue.pricePerHour * selectedDuration;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Text(
          widget.venue.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Color(0xFFA1A1A1)),
                  SizedBox(width: 8),
                  Text(
                    "Back to Venues",
                    style: TextStyle(color: Color(0xFFA1A1A1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Venue Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.venue.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF808080), Color(0xFF606060)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "⚽ Football",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("📍", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        widget.venue.location,
                        style: const TextStyle(color: Color(0xFFA1A1A1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202020),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Capacity",
                                style: TextStyle(color: Color(0xFFA1A1A1), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.venue.capacity} people",
                                style: const TextStyle(
                                  color: Color(0xFFEAEAEA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202020),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Price per Hour",
                                style: TextStyle(color: Color(0xFFA1A1A1), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${widget.venue.pricePerHour}",
                                style: const TextStyle(
                                  color: Color(0xFFEAEAEA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.venue.description,
                    style: const TextStyle(color: Color(0xFFCFCFCF)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Check authentication
            if (!request.loggedIn)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 48,
                      color: Color(0xFFEAEAEA),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Login Required",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You need to be logged in to book a venue.",
                      style: TextStyle(
                        color: Color(0xFFCFCFCF),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              foregroundColor: const Color(0xFFEAEAEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Login"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Navigate to register page
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Register coming soon!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEAEAEA)),
                              foregroundColor: const Color(0xFFEAEAEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Create Account"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              // Booking Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Book This Venue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date and Time
                    Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _selectDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF161616),
                                foregroundColor: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? dateFormat.format(selectedDate!)
                                    : "Select Date",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Time",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _selectTime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF161616),
                                foregroundColor: const Color(0xFFEAEAEA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : "Select Time",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration
                  const Text(
                    "Duration (hours)",
                    style: TextStyle(color: Color(0xFFCFCFCF)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3, 4].map((duration) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedDuration = duration;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedDuration == duration
                                  ? const Color(0xFF343434)
                                  : const Color(0xFF2A2A2A),
                              foregroundColor: const Color(0xFFEAEAEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: Text("$duration hour${duration > 1 ? 's' : ''}"),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Price Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202020),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Price per hour:",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                            Text(
                              "Rp ${widget.venue.pricePerHour}",
                              style: const TextStyle(color: Color(0xFFEAEAEA)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Duration:",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                            Text(
                              "$selectedDuration hour${selectedDuration > 1 ? 's' : ''}",
                              style: const TextStyle(color: Color(0xFFEAEAEA)),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF2A2A2A)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total:",
                              style: TextStyle(
                                color: Color(0xFFEAEAEA),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Rp $totalPrice",
                              style: const TextStyle(
                                color: Color(0xFFEAEAEA),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: const Color(0xFFEAEAEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rules and Help
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text("✅", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              "Booking Rules",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRule("Bookings must be made at least 2 hours in advance"),
                        _buildRule("Maximum booking duration is 4 hours per session"),
                        _buildRule("Cancellations must be made 24 hours before booking time"),
                        _buildRule("Bring your own equipment unless specified"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text("📞", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              "Need Help?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Text("📧", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              "support@hoppin.com",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Text("📱", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              "+1 (555) 123-4567",
                              style: TextStyle(color: Color(0xFFCFCFCF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFEAEAEA),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFCFCFCF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}