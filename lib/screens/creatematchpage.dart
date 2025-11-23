import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../matches/services/match_service.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final titleC = TextEditingController();
  final categoryC = TextEditingController();
  final locationC = TextEditingController();
  final maxMembersC = TextEditingController();
  final descriptionC = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final service = MatchService(request);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Match"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleC,
            decoration: const InputDecoration(labelText: "Match Title"),
          ),
          TextField(
            controller: categoryC,
            decoration: const InputDecoration(labelText: "Sport Category"),
          ),
          TextField(
            controller: locationC,
            decoration: const InputDecoration(labelText: "Location"),
          ),
          TextField(
            controller: maxMembersC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Max Members"),
          ),
          const SizedBox(height: 10),
          Text(
            selectedDate == null
                ? "Pick Date"
                : selectedDate.toString(),
          ),
          ElevatedButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
              );
              if (d != null) {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) {
                  setState(() {
                    selectedDate = DateTime(
                      d.year, d.month, d.day, t.hour, t.minute,
                    );
                  });
                }
              }
            },
            child: const Text("Pick Date/Time"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionC,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (selectedDate == null) return;

              final ok = await service.createMatch(
                title: titleC.text,
                category: categoryC.text,
                location: locationC.text,
                maxMembers: int.parse(maxMembersC.text),
                eventDate: selectedDate!.toIso8601String(),
                description: descriptionC.text,
              );

              if (!mounted) return;

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Match created!")),
                );
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to create match")),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
