// To parse this JSON data, do
//
//     final match = matchFromJson(jsonString);

import 'dart:convert';

Match matchFromJson(String str) => Match.fromJson(json.decode(str));

String matchToJson(Match data) => json.encode(data.toJson());

class Match {
    bool success;
    int count;
    List<MatchElement> matches;

    Match({
        required this.success,
        required this.count,
        required this.matches,
    });

    factory Match.fromJson(Map<String, dynamic> json) => Match(
        success: json["success"],
        count: json["count"],
        matches: List<MatchElement>.from(json["matches"].map((x) => MatchElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "count": count,
        "matches": List<dynamic>.from(matches.map((x) => x.toJson())),
    };
}

class MatchElement {
    String id;
    String title;
    String category;
    String categorySlug;
    String location;
    DateTime eventDate;
    String description;
    int maxMembers;
    int currentMembers;
    int availableSlots;

    MatchElement({
        required this.id,
        required this.title,
        required this.category,
        required this.categorySlug,
        required this.location,
        required this.eventDate,
        required this.description,
        required this.maxMembers,
        required this.currentMembers,
        required this.availableSlots,
    });

    factory MatchElement.fromJson(Map<String, dynamic> json) => MatchElement(
        id: json["id"],
        title: json["title"],
        category: json["category"],
        categorySlug: json["category_slug"],
        location: json["location"],
        eventDate: DateTime.parse(json["event_date"]),
        description: json["description"],
        maxMembers: json["max_members"],
        currentMembers: json["current_members"],
        availableSlots: json["available_slots"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category,
        "category_slug": categorySlug,
        "location": location,
        "event_date": eventDate.toIso8601String(),
        "description": description,
        "max_members": maxMembers,
        "current_members": currentMembers,
        "available_slots": availableSlots,
    };
}
