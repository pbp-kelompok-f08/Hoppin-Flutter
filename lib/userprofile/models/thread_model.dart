class ThreadUser {
  final String username;
  final String? profilePicture;

  ThreadUser({
    required this.username,
    this.profilePicture,
  });

  factory ThreadUser.fromJson(Map<String, dynamic> json) {
    return ThreadUser(
      username: json['username'] ?? 'Anonymous',
      profilePicture: json['profile_picture'],
    );
  }
}

class ThreadModel {
  final String id;
  final ThreadUser user;
  final String content;
  final String? tags;
  final String? image;
  final int likeCount;
  final int replyCount;
  final DateTime createdAt;
  final bool isLiked;

  ThreadModel({
    required this.id,
    required this.user,
    required this.content,
    this.tags,
    this.image,
    required this.likeCount,
    required this.replyCount,
    required this.createdAt,
    this.isLiked = false,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      id: json['id'] ?? '',
      user: ThreadUser.fromJson(json['user'] ?? {}),
      content: json['content'] ?? '',
      tags: json['tags'],
      image: json['image'],
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      isLiked: json['isLiked'] ?? false,
    );
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}