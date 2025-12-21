// To parse this JSON data, do
//
//     final threads = threadsFromJson(jsonString);

import 'dart:convert';

List<Threads> threadsFromJson(String str) => List<Threads>.from(json.decode(str).map((x) => Threads.fromJson(x)));

String threadsToJson(List<Threads> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Threads {
    User user;
    String id;
    String content;
    String tags;
    String image;
    int likeCount;
    int shareCount;
    int replyCount;
    DateTime createdAt;
    bool isLiked;

    Threads({
        required this.user,
        required this.id,
        required this.content,
        required this.tags,
        required this.image,
        required this.likeCount,
        required this.shareCount,
        required this.replyCount,
        required this.createdAt,
        required this.isLiked,
    });

    factory Threads.fromJson(Map<String, dynamic> json) => Threads(
        user: User.fromJson(json["user"]),
        id: json["id"],
        content: json["content"],
        tags: json["tags"],
        image: json["image"],
        likeCount: json["likeCount"],
        shareCount: json["shareCount"],
        replyCount: json["replyCount"],
        createdAt: DateTime.parse(json["created_at"]),
        isLiked: json["isLiked"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "id": id,
        "content": content,
        "tags": tags,
        "image": image,
        "likeCount": likeCount,
        "shareCount": shareCount,
        "replyCount": replyCount,
        "created_at": createdAt.toIso8601String(),
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
