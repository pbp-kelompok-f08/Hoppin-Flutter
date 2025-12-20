// To parse this JSON data, do
//
//     final chat = chatFromJson(jsonString);

import 'dart:convert';

List<Chat> chatFromJson(String str) => List<Chat>.from(json.decode(str).map((x) => Chat.fromJson(x)));

String chatToJson(List<Chat> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chat {
    String id;
    String username;
    String message;
    DateTime createdAt;
    dynamic replyTo;
    String profilePicture;
    bool isMe;

    Chat({
        required this.id,
        required this.username,
        required this.message,
        required this.createdAt,
        required this.replyTo,
        required this.profilePicture,
        required this.isMe,
    });

    factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"],
        username: json["username"],
        message: json["message"],
        createdAt: DateTime.parse(json["createdAt"]),
        replyTo: json["replyTo"],
        profilePicture: json["profile_picture"],
        isMe: json["is_me"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
        "replyTo": replyTo,
        "profile_picture": profilePicture,
        "is_me": isMe,
    };
}
