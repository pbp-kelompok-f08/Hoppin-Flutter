import 'package:flutter/material.dart';
import 'package:flutter_hoppin/colors.dart';
import 'package:flutter_hoppin/livechat/models/group_model.dart';
import 'package:intl/intl.dart';

class groupEntrySection extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const groupEntrySection({
    super.key,
    required this.group,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final hasChat = group.lastChat != null;

    return Material(
      color: MainColors.primaryColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: MainColors.secondaryColor,
                child: Text(
                  group.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: MainColors.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== NAME + TIME =====
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MainColors.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (group.lastChat != null)
                          Text(
                            _formatTime(group.lastChat!.createdAt),
                            style: TextStyle(
                              color: MainColors.secondaryCardColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // ===== LAST CHAT =====
                    Text(
                      group.lastChat != null 
                          ? group.lastChat!.toString() 
                          : 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: MainColors.secondaryCardColor,
                        fontSize: 14,
                        fontStyle: group.lastChat == null 
                            ? FontStyle.italic 
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
