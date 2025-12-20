import 'dart:convert';

List<Group> groupFromJson(String str) => List<Group>.from(json.decode(str).map((x) => Group.fromJson(x)));

String groupToJson(List<Group> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Group {
    String id;
    String match;
    String name;
    List<String> members;
    LastChat lastChat;

    Group({
        required this.id,
        required this.match,
        required this.name,
        required this.members,
        required this.lastChat,
    });

    factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"],
        match: json["match"],
        name: json["name"],
        members: List<String>.from(json["members"].map((x) => x)),
        lastChat: LastChat.fromJson(json["last_chat"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "match": match,
        "name": name,
        "members": List<dynamic>.from(members.map((x) => x)),
        "last_chat": lastChat.toJson(),
    };
}

class LastChat {
    String username;
    String message;
    DateTime createdAt;

    LastChat({
        required this.username,
        required this.message,
        required this.createdAt,
    });

    factory LastChat.fromJson(Map<String, dynamic> json) => LastChat(
        username: json["username"],
        message: json["message"],
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
    };

    @override
    String toString()
    {
      return "$username: $message";
    }
}
