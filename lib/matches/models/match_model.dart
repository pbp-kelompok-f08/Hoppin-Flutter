class MatchResponse {
  final bool success;
  final int count;
  final List<MatchItem> matches;

  MatchResponse({
    required this.success,
    required this.count,
    required this.matches,
  });

  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    return MatchResponse(
      success: json["success"] ?? true,
      count: json["count"] ?? 0,
      matches: (json["matches"] as List)
          .map((e) => MatchItem.fromJson(e))
          .toList(),
    );
  }
}

class MatchItem {
  final String id;
  final String title;
  final String category;
  final String location;
  final DateTime eventDate;
  final String description;
  final int maxMembers;
  final int currentMembers;
  final int availableSlots;

  MatchItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.eventDate,
    required this.description,
    required this.maxMembers,
    required this.currentMembers,
    required this.availableSlots,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json["id"],
      title: json["title"],
      category: json["category"],
      location: json["location"],
      eventDate: DateTime.parse(json["event_date"]),
      description: json["description"] ?? "",
      maxMembers: json["max_members"],
      currentMembers: json["current_members"],
      availableSlots: json["available_slots"],
    );
  }
}
