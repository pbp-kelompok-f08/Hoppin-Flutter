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
    final response =
        await request.get('http://localhost:8000/liveChat/group/');

    final datas = response["data"] as List;
    return datas.map((e) => Group.fromJson(e)).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();
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

