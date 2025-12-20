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

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final request = context.read<CookieRequest>();
    _service = MatchService(request);
    _futureMatches = _service.fetchMatches();

    _initialized = true;
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchC,
              onChanged: (_) => _applySearch(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                hintText: "Search matches...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1F1F1F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<MatchResponse>(
                future: _futureMatches,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white),
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

                  if (!snapshot.hasData ||
                      snapshot.data!.matches.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matches found",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final matches = snapshot.data!.matches;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: matches.length,
                    itemBuilder: (context, i) =>
                        _buildMatchCard(matches[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchItem m) {
    final isFull = m.availableSlots <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        color: const Color(0xFF161616),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.category,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "📍 ${m.location}",
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slot ${m.currentMembers}/${m.maxMembers}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  ElevatedButton(
                    onPressed: isFull ? null : () => _handleJoin(m),
                    child: Text(isFull ? "Full" : "Join"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
