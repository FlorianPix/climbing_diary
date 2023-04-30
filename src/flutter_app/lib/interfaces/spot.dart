import 'package:climbing_diary/interfaces/update_spot.dart';

class Spot {
  final List<String> mediaIds;
  final List<String> routeIds;
  final String id;
  final String userId;

  final String comment;
  final List<double> coordinates;
  final int distanceParking;
  final int distancePublicTransport;
  final String location;
  final String name;
  final int rating;

  const Spot({
    required this.mediaIds,
    required this.routeIds,
    required this.id,
    required this.userId,
    required this.comment,
    required this.coordinates,
    required this.distanceParking,
    required this.distancePublicTransport,
    required this.location,
    required this.name,
    required this.rating,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      mediaIds: List<String>.from(json['media_ids']),
      routeIds: List<String>.from(json['route_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      coordinates: List<double>.from(json['coordinates']),
      distanceParking: json['distance_parking'],
      distancePublicTransport: json['distance_public_transport'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory Spot.fromCache(Map<dynamic, dynamic> cache) {
    return Spot(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      routeIds: cache['routes'] != null ? List<String>.from(cache['routes']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      coordinates: List<double>.from(cache['coordinates']),
      distanceParking: cache['distance_parking'],
      distancePublicTransport: cache['distance_public_transport'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "route_ids": routeIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "coordinates": coordinates,
    "distance_parking": distanceParking,
    "distance_public_transport": distancePublicTransport,
    "location": location,
    "name": name,
    "rating": rating,
  };

  UpdateSpot toUpdateSpot() {
    return UpdateSpot(
      mediaIds: mediaIds,
      routeIds: routeIds,
      id: id,
      userId: userId,
      comment: comment,
      coordinates: coordinates,
      distanceParking: distanceParking,
      distancePublicTransport: distancePublicTransport,
      location: location,
      name: name,
      rating: rating,
    );
  }
}