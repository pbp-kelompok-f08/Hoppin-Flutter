// To parse this JSON data, do
//
//     final reply = replyFromJson(jsonString);

import 'dart:convert';

List<Reply> replyFromJson(String str) => List<Reply>.from(json.decode(str).map((x) => Reply.fromJson(x)));

String replyToJson(List<Reply> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reply {
    User user;
    String id;
    String threadId;
    String content;
    DateTime createdAt;
    int likeCount;
    bool isLiked;

    Reply({
        required this.user,
        required this.id,
        required this.threadId,
        required this.content,
        required this.createdAt,
        required this.likeCount,
        required this.isLiked,
    });

    factory Reply.fromJson(Map<String, dynamic> json) => Reply(
        user: User.fromJson(json["user"]),
        id: json["id"],
        threadId: json["thread_id"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        likeCount: json["likeCount"],
        isLiked: json["isLiked"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "id": id,
        "thread_id": threadId,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "likeCount": likeCount,
        "isLiked": isLiked,
    };
}

class User {
    String username;
    String profilePicture;

    User({
        required this.username,
        required this.profilePicture,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        profilePicture: json["profile_picture"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "profile_picture": profilePicture,
    };
}
