import 'package:flutter/material.dart';
import 'package:flutter_hoppin/userprofile/models/thread_model.dart';

class ThreadCard extends StatelessWidget {
  final ThreadModel thread;

  const ThreadCard({
    super.key,
    required this.thread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: thread.user.profilePicture != null
                      ? NetworkImage(thread.user.profilePicture!)
                      : null, 
                  backgroundColor: Colors.grey[800],
                  child: thread.user.profilePicture == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)  
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${thread.user.username}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        thread.getFormattedDate(),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thread image (if exists)
            if (thread.image != null && thread.image!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  thread.image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

            // Content
            Text(
              thread.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // Tags
            if (thread.tags != null && thread.tags!.isNotEmpty)
              Text(
                '#${thread.tags!.replaceAll(',', ' #')}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Icon(
                  thread.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: thread.isLiked ? Colors.red : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${thread.likeCount}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${thread.replyCount}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}