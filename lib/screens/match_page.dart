import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../matches/models/match_model.dart';
import '../matches/services/match_service.dart';
import 'package:flutter_hoppin/screens/creatematchpage.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late MatchService _service;
  late Future<MatchResponse> _futureMatches;

  final TextEditingController searchC = TextEditingController();
  String filterSport = "";
  String filterWhen = "";

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _service = MatchService(request);
    _futureMatches = _service.fetchMatches();
  }

  void _applySearch() {
    setState(() {
      _futureMatches = _service.fetchMatches(
        keyword: searchC.text,
        sport: filterSport,
        when: filterWhen,
      );
    });
  }

  Future<void> _refresh() async {
    _applySearch();
  }

  Future<void> _handleJoin(MatchItem match) async {
    try {
      final ok = await _service.joinMatch(match.id);

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil join match")),
        );
        _applySearch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal join match")),
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
          "Find Your Match",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateMatchPage(),
                ),
              );
              if (refresh == true) _applySearch();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Create Match",
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Search bar =====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: searchC,
              onChanged: (_) => _applySearch(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70, size: 20),
                hintText: "Search matches…",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ===== Filters row =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    label: "Sport",
                    value: filterSport.isEmpty ? null : filterSport,
                    items: const [
                      DropdownMenuItem(
                        value: "sepak-bola",
                        child: Text("Sepak Bola",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "basket",
                        child: Text("Basket",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "bulu-tangkis",
                        child: Text("Bulu Tangkis",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "futsal",
                        child: Text("Futsal",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => filterSport = v ?? "");
                      _applySearch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown(
                    label: "When",
                    value: filterWhen.isEmpty ? null : filterWhen,
                    items: const [
                      DropdownMenuItem(
                        value: "today",
                        child: Text("Today",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "week",
                        child: Text("This Week",
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: "month",
                        child: Text("This Month",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => filterWhen = v ?? "");
                      _applySearch();
                    },
                  ),
                ),
              ],
            ),
          ),

          // ===== List =====
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<MatchResponse>(
                future: _futureMatches,
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

                  if (!snapshot.hasData || snapshot.data!.matches.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matches found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final matches = snapshot.data!.matches;

                  // === Group by category ===
                  final Map<String, List<MatchItem>> grouped = {};
                  for (final m in matches) {
                    grouped.putIfAbsent(m.category, () => []).add(m);
                  }
                  final categories = grouped.keys.toList()..sort();

                  final List<Widget> children = [];
                  for (final cat in categories) {
                    final items = grouped[cat]!;
                    children.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                        child: Text(
                          cat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                    for (final m in items) {
                      children.add(_buildMatchCard(m));
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: children,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====== widgets helper ======

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(999),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items,
        isExpanded: true,
        dropdownColor: const Color(0xFF1C1C1C),
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white70,
        hint: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMatchCard(MatchItem m) {
    final isFull = m.availableSlots <= 0;
    final dateString =
        "${m.eventDate.day.toString().padLeft(2, '0')}/${m.eventDate.month.toString().padLeft(2, '0')}/${m.eventDate.year} "
        "${m.eventDate.hour.toString().padLeft(2, '0')}:${m.eventDate.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        color: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      m.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      m.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "📍 ${m.location}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                "🕒 $dateString",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              if (m.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  m.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slot: ${m.currentMembers} / ${m.maxMembers}",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    isFull ? "Full" : "${m.availableSlots} left",
                    style: TextStyle(
                      color: isFull ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFull ? null : () => _handleJoin(m),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isFull ? "Match Full" : "Join Match",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
