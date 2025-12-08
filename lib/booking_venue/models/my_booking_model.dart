import 'dart:convert';
import 'venue_model.dart';

MyBookingModel myBookingModelFromJson(String str) => MyBookingModel.fromJson(json.decode(str));

String myBookingModelToJson(MyBookingModel data) => json.encode(data.toJson());

class MyBookingModel {
     List<MyBooking> bookings;

     MyBookingModel({
         required this.bookings,
     });

     factory MyBookingModel.fromJson(Map<String, dynamic> json) => MyBookingModel(
         bookings: List<MyBooking>.from(json["bookings"].map((x) => MyBooking.fromJson(x))),
     );

     Map<String, dynamic> toJson() => {
         "bookings": List<dynamic>.from(bookings.map((x) => x.toJson())),
     };
}

class MyBooking {
     String id;
     Venue venue;
     DateTime date;
     String time;
     String status;

     MyBooking({
         required this.id,
         required this.venue,
         required this.date,
         required this.time,
         required this.status,
     });

     factory MyBooking.fromJson(Map<String, dynamic> json) => MyBooking(
         id: json["id"],
         venue: Venue.fromJson(json["venue"]),
         date: DateTime.parse(json["date"]),
         time: json["time"],
         status: json["status"],
     );

     Map<String, dynamic> toJson() => {
         "id": id,
         "venue": venue.toJson(),
         "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
         "time": time,
         "status": status,
     };
}