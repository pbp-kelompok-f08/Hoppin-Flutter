import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter_hoppin/models/match.dart';  
import 'package:flutter_hoppin/widgets/left_drawer.dart';
import 'package:flutter_hoppin/matches/widgets/match_card.dart';

class MatchEntryListPage extends StatefulWidget {
  const MatchEntryListPage({super.key});

  @override
  State<MatchEntryListPage> createState() => _MatchEntryListPageState();
}

class _MatchEntryListPageState extends State<MatchEntryListPage> {
  Future<List<MatchElement>> fetchMatches(CookieRequest request) async {
    final response = await request.get(
      "http://10.0.2.2:8000/matches/json/",  // sesuaikan url kamu
    );

    final matchData = Match.fromJson(response);
    return matchData.matches; 
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Matches"),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchMatches(request),
        builder: (context, AsyncSnapshot<List<MatchElement>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada match yang tersedia.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final matches = snapshot.data!;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return MatchCard(
                match: matches[index],
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("Clicked: ${matches[index].title}"),
                      ),
                    );
                },
              );
            },
          );
        },
      ),
    );
  }
}
