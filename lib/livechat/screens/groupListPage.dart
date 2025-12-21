import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hoppin/colors.dart';
import 'package:flutter_hoppin/livechat/models/group_model.dart';
import 'package:flutter_hoppin/livechat/widgets/groupEntrySection.dart';
import 'package:flutter_hoppin/livechat/screens/chatPage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late Future<List<Group>> _groupsFuture;

  Future<List<Group>> fetchGroups(CookieRequest request) async {
    try {
    final response =
          await request.get('https://dion-wisdom-hoppin.pbp.cs.ui.ac.id/liveChat/group/');

      // Handle null response
      if (response == null) {
        return [];
      }

      // Check if response is a String (HTML/error) instead of Map (JSON)
      if (response is String) {
        if (response.trim().startsWith('<!') || response.trim().startsWith('<!DOCTYPE')) {
          throw Exception('Server returned HTML error page instead of JSON.\n\nPlease check:\n1. Is the Django server running?\n2. Does the endpoint /liveChat/group/ exist?\n\nError response preview: ${response.substring(0, response.length > 300 ? 300 : response.length)}');
        }
        // If it's a string but not HTML, try to decode it
        final decoded = json.decode(response) as Map<String, dynamic>;
        final datas = decoded["data"] as List?;
        if (datas == null) return [];
        return datas.map((e) => Group.fromJson(e as Map<String, dynamic>)).toList();
      }

      // Response should be a Map<String, dynamic>
      if (response is! Map<String, dynamic>) {
        return [];
      }
      
      final datas = response["data"] as List?;
      if (datas == null) return [];
      
      return datas.map((e) {
        try {
          return Group.fromJson(e as Map<String, dynamic>);
        } catch (e) {
          // Skip invalid entries
          return null;
        }
      }).whereType<Group>().toList();
    } catch (e) {
      if (e.toString().contains('<!Doctype') || 
          e.toString().contains('<!DOCTYPE') ||
          e.toString().contains('Unexpected token')) {
        throw Exception('JSON parsing error - Server returned HTML instead of JSON.\n\nPlease check:\n1. Is the Django server running?\n2. Does the endpoint /liveChat/group/ exist?\n3. Verify the endpoint returns JSON, not HTML\n\nOriginal error: $e');
      }
      // Return empty list on error instead of crashing
      return [];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
    
    // Check if user is logged in
    if (!request.loggedIn) {
      // User not logged in, set empty future to avoid errors
      _groupsFuture = Future.value(<Group>[]);
      return;
    }
    
    _groupsFuture = fetchGroups(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.primaryColor,
      appBar: AppBar(
        backgroundColor: MainColors.secondaryColor,
        title: const Text(
          'Live Chat',
          style: TextStyle(color: MainColors.primaryTextColor),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<Group>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // 📭 Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "You haven't joined any match.\nJoin a match to join its group.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: MainColors.primaryTextColor,
                  ),
                ),
              ),
            );
          }

          // ✅ Data loaded
          final groups = snapshot.data!;

          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.grey.shade800,
              height: 1,
            ),
            itemBuilder: (context, index) {
              return groupEntrySection(
                group: groups[index],
                onTap: () {
                  final group = groups[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatListPage(
                        groupId: group.id,
                        groupName: group.name,
                      ),
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

