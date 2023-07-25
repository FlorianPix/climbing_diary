import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/spot/update_spot.dart';

class Spot extends MyBaseInterface{
  final List<String> singlePitchRouteIds;
  final List<String> multiPitchRouteIds;

  final String comment;
  final List<double> coordinates;
  final int distanceParking;
  final int distancePublicTransport;
  final String location;
  final String name;
  final int rating;

  const Spot({
    required super.mediaIds,
    required this.singlePitchRouteIds,
    required this.multiPitchRouteIds,
    required super.id,
    required super.userId,
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
      singlePitchRouteIds: List<String>.from(json['single_pitch_route_ids']),
      multiPitchRouteIds: List<String>.from(json['multi_pitch_route_ids']),
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
      singlePitchRouteIds: cache['single_pitch_route_ids'] != null ? List<String>.from(cache['single_pitch_route_ids']) : [],
      multiPitchRouteIds: cache['multi_pitch_route_ids'] != null ? List<String>.from(cache['multi_pitch_route_ids']) : [],
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
    "single_pitch_route_ids": singlePitchRouteIds,
    "multi_pitch_route_ids": multiPitchRouteIds,
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
      singlePitchRouteIds: singlePitchRouteIds,
      multiPitchRouteIds: multiPitchRouteIds,
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