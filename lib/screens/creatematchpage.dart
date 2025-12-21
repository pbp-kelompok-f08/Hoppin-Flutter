import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../matches/services/match_service.dart';
import '../colors.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final titleC = TextEditingController();
  final locationC = TextEditingController();
  final maxMembersC = TextEditingController();
  final descriptionC = TextEditingController();
  DateTime? selectedDate;
  String? selectedCategory;
  bool _isLoading = false;

  // Default categories from Django (matches DEFAULT_CATEGORIES in views.py)
  final List<String> categories = [
    'Sepak Bola',
    'Basket',
    'Bulu Tangkis',
    'Futsal',
    'Lari',
    'Bersepeda',
    'Other',
  ];

  @override
  void dispose() {
    titleC.dispose();
    locationC.dispose();
    maxMembersC.dispose();
    descriptionC.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) {
                  setState(() {
          selectedDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  });
                }
              }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a sport category")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select event date and time")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = context.read<CookieRequest>();
      final service = MatchService(request);

      // Format date to match Django's datetime-local format (YYYY-MM-DDTHH:MM)
      final formattedDate = selectedDate!.toIso8601String().substring(0, 16);

              final ok = await service.createMatch(
        title: titleC.text.trim(),
        category: selectedCategory!,
        location: locationC.text.trim(),
        maxMembers: int.parse(maxMembersC.text.trim()),
        eventDate: formattedDate,
        description: descriptionC.text.trim(),
              );

              if (!mounted) return;

              if (ok) {
                Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Match created successfully!")),
        );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to create match")),
                );
              }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.primaryColor,
      appBar: AppBar(
        backgroundColor: MainColors.secondaryColor,
        title: const Text(
          "Create Match",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: titleC,
                decoration: InputDecoration(
                  labelText: "Match Title *",
                  labelStyle: const TextStyle(color: MainColors.placeholderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: MainColors.placeholderColor,
                      width: 2,
                    ),
                  ),
                  fillColor: MainColors.secondaryColor,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                maxLength: 120,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a match title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Sport Category *",
                  labelStyle: const TextStyle(color: MainColors.placeholderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: MainColors.placeholderColor,
                      width: 2,
                    ),
                  ),
                  fillColor: MainColors.secondaryColor,
                  filled: true,
                ),
                dropdownColor: MainColors.secondaryColor,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a sport category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location field
              TextFormField(
                controller: locationC,
                decoration: InputDecoration(
                  labelText: "Location *",
                  labelStyle: const TextStyle(color: MainColors.placeholderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: MainColors.placeholderColor,
                      width: 2,
                    ),
                  ),
                  fillColor: MainColors.secondaryColor,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                maxLength: 150,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Max Members field
              TextFormField(
                controller: maxMembersC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Max Members *",
                  labelStyle: const TextStyle(color: MainColors.placeholderColor),
                  hintText: "e.g., 10",
                  hintStyle: const TextStyle(color: MainColors.placeholderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: MainColors.placeholderColor,
                      width: 2,
                    ),
                  ),
                  fillColor: MainColors.secondaryColor,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter max members';
                  }
                  final intValue = int.tryParse(value.trim());
                  if (intValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (intValue <= 0) {
                    return 'Max members must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date & Time picker
              OutlinedButton(
                onPressed: _pickDateTime,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: MainColors.placeholderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? "Select Date & Time *"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
          ),
        ],
                ),
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: descriptionC,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: MainColors.placeholderColor),
                  hintText: "Describe your match (optional)",
                  hintStyle: const TextStyle(color: MainColors.placeholderColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: MainColors.placeholderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: MainColors.placeholderColor,
                      width: 2,
                    ),
                  ),
                  fillColor: MainColors.secondaryColor,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) => null,
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: MainColors.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Match',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
