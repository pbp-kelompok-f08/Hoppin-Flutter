import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;

  const ChatItem({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            chat.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== AVATAR (LEFT) =====
          if (!chat.isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(chat.profilePicture),
            ),
            const SizedBox(width: 8),
          ],

          // ===== CHAT BUBBLE =====
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 72,
                maxWidth: maxBubbleWidth,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chat.isMe
                      ? Colors.green.shade700
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // USERNAME (optional: hide kalau chat.isMe)
                    if (!chat.isMe)
                      Text(
                        chat.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),

                    if (!chat.isMe) const SizedBox(height: 4),

                    // MESSAGE + TIME
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: chat.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: chat.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const WidgetSpan(
                            child: SizedBox(width: 8),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Text(
                              _formatTime(chat.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: chat.isMe
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== AVATAR (RIGHT) =====
          if (chat.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(chat.profilePicture),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}
