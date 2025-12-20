import 'package:flutter/material.dart';
import 'package:flutter_hoppin/colors.dart';
import '../models/chat_model.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final Function(String)? onEdit;
  final VoidCallback? onDelete;

  const ChatItem({
    super.key,
    required this.chat,
    this.onEdit,
    this.onDelete,
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
          if (!chat.isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(chat.profilePicture),
            ),
            const SizedBox(width: 8),
          ],

          // ===== ACTION BUTTONS (ME ONLY) =====
          if (chat.isMe) ...[
            Row(
              children: [
                _ActionButton(
                  icon: Icons.edit,
                  onTap: () => _showEditDialog(context),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete,
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
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
                      : MainColors.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: chat.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!chat.isMe)
                      Text(
                        chat.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white
                        ),
                      ),

                    if (!chat.isMe) const SizedBox(height: 4),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: chat.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const WidgetSpan(child: SizedBox(width: 8)),
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

  // ================= EDIT DIALOG =================
  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: chat.message);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit pesan'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Edit pesan...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newMessage = controller.text.trim();
              if (newMessage.isNotEmpty && onEdit != null) {
                onEdit!(newMessage);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ================= DELETE DIALOG =================
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus pesan'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus pesan ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              if (onDelete != null) onDelete!();
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}

// ===== ACTION BUTTON =====
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
