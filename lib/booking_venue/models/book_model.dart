import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
    List<Booking> bookings;

    BookModel({
        required this.bookings,
    });

    factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        bookings: List<Booking>.from(json["bookings"].map((x) => Booking.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "bookings": List<dynamic>.from(bookings.map((x) => x.toJson())),
    };
}

class Booking {
    String id;
    String user;
    String venue;
    DateTime date;
    String time;
    String status;

    Booking({
        required this.id,
        required this.user,
        required this.venue,
        required this.date,
        required this.time,
        required this.status,
    });

    factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        user: json["user"],
        venue: json["venue"],
        date: DateTime.parse(json["date"]),
        time: json["time"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "venue": venue,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "status": status,
    };
}
