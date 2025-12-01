import 'dart:convert';

VenueModel venueModelFromJson(String str) => VenueModel.fromJson(json.decode(str));

String venueModelToJson(VenueModel data) => json.encode(data.toJson());

class VenueModel {
    List<Venue> venues;

    VenueModel({
        required this.venues,
    });

    factory VenueModel.fromJson(Map<String, dynamic> json) => VenueModel(
        venues: List<Venue>.from(json["venues"].map((x) => Venue.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "venues": List<dynamic>.from(venues.map((x) => x.toJson())),
    };
}

class Venue {
    String id;
    String name;
    String location;
    int capacity;
    String description;
    int pricePerHour;

    Venue({
        required this.id,
        required this.name,
        required this.location,
        required this.capacity,
        required this.description,
        required this.pricePerHour,
    });

    factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json["id"],
        name: json["name"],
        location: json["location"],
        capacity: json["capacity"],
        description: json["description"],
        pricePerHour: json["price_per_hour"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "location": location,
        "capacity": capacity,
        "description": description,
        "price_per_hour": pricePerHour,
    };
}
