import 'dart:convert';

List<Group> groupFromJson(String str) =>
    List<Group>.from(json.decode(str).map((x) => Group.fromJson(x)));

String groupToJson(List<Group> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Group {
    String id;
    String match;
    String name;
    List<String> members;
    LastChat? lastChat;

    Group({
        required this.id,
        required this.match,
        required this.name,
        required this.members,
        this.lastChat,
    });

    factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json["id"]?.toString() ?? '',
        match: json["match"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
        members: json["members"] != null 
            ? List<String>.from(json["members"].map((x) => x.toString()))
            : [],
        lastChat: json["last_chat"] != null 
            ? LastChat.fromJson(json["last_chat"] as Map<String, dynamic>)
            : null,
    );

  Map<String, dynamic> toJson() => {
        "id": id,
        "match": match,
        "name": name,
        "members": List<dynamic>.from(members.map((x) => x)),
        "last_chat": lastChat?.toJson(),
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

    factory LastChat.fromJson(Map<String, dynamic> json) {
      // Handle username as string or integer (Django might return user PK)
      String usernameStr = json["username"]?.toString() ?? 'Unknown';
      
      // Handle createdAt - might be string or DateTime
      DateTime createdAtDate;
      if (json["createdAt"] is String) {
        createdAtDate = DateTime.parse(json["createdAt"]);
      } else if (json["createdAt"] is DateTime) {
        createdAtDate = json["createdAt"] as DateTime;
      } else {
        // Fallback to now if parsing fails
        createdAtDate = DateTime.now();
      }
      
      return LastChat(
        username: usernameStr,
        message: json["message"]?.toString() ?? '',
        createdAt: createdAtDate,
      );
    }

  Map<String, dynamic> toJson() => {
        "username": username,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
      };

  @override
  String toString() => "$username: $message";
}
