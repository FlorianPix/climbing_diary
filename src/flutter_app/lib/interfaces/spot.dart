import 'package:climbing_diary/interfaces/update_spot.dart';

class Spot {
  final String id;
  final String date;
  final String name;
  final List<double> coordinates;
  final List<String> location;
  final List<String> routes;
  final int rating;
  final String comment;
  final int distanceParking;
  final int distancePublicTransport;
  final List<String> mediaIds;

  const Spot({
    required this.id,
    required this.date,
    required this.name,
    required this.coordinates,
    required this.location,
    required this.routes,
    required this.rating,
    required this.comment,
    required this.distanceParking,
    required this.distancePublicTransport,
    required this.mediaIds
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['_id'],
      date: json['date'],
      name: json['name'],
      coordinates: List<double>.from(json['coordinates']),
      location: List<String>.from(json['location']),
      routes: List<String>.from(json['routes']),
      rating: json['rating'],
      comment: json['comment'],
      distanceParking: json['distance_parking'],
      distancePublicTransport: json['distance_public_transport'],
      mediaIds: List<String>.from(json['media_ids'])
    );
  }

  factory Spot.fromCache(Map<dynamic, dynamic> cache) {
    return Spot(
      id: cache['_id'],
      date: cache['date'],
      name: cache['name'],
      coordinates: List<double>.from(cache['coordinates']),
      location: List<String>.from(cache['location']),
      routes: cache['routes'] != null ? List<String>.from(cache['routes']) : [],
      rating: cache['rating'],
      comment: cache['comment'],
      distanceParking: cache['distance_parking'],
      distancePublicTransport: cache['distance_public_transport'],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : []
    );
  }

  Map toJson() => {
    "_id": id,
    "date": date,
    "name": name,
    "coordinates": coordinates,
    "location": location,
    "routes": routes,
    "rating": rating,
    "comment": comment,
    "distance_parking": distanceParking,
    "distance_public_transport": distancePublicTransport,
    "media_ids": mediaIds
  };

  UpdateSpot toUpdateSpot() {
    return UpdateSpot(
      id: id,
      date: date,
      name: name,
      coordinates: coordinates,
      location: location,
      routes: routes,
      rating: rating,
      comment: comment,
      distanceParking: distanceParking,
      distancePublicTransport: distancePublicTransport,
      mediaIds: mediaIds
    );
  }
}