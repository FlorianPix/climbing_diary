import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/spot/update_spot.dart';

class Spot extends MyBaseInterface{
  static const String boxName = 'spots';
  static const String deleteBoxName = 'delete_spots';

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
    required super.updated,
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
      updated: json['updated'],
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
      updated: cache['updated'],
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

  @override
  Map toJson() => {
    "updated": updated,
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

  @override
  int get hashCode {
    int mediaIdsHashCode = 0;
    for (String mediaId in mediaIds) {
      if (mediaIdsHashCode == 0) {
        mediaIdsHashCode = mediaId.hashCode;
      } else {
        mediaIdsHashCode = mediaIdsHashCode ^ mediaId.hashCode;
      }
    }
    int singlePitchRouteIdsHashCode = 0;
    for (String singlePitchRouteId in singlePitchRouteIds) {
      if (singlePitchRouteIdsHashCode == 0) {
        singlePitchRouteIdsHashCode = singlePitchRouteId.hashCode;
      } else {
        singlePitchRouteIdsHashCode = singlePitchRouteIdsHashCode ^ singlePitchRouteId.hashCode;
      }
    }
    int multiPitchRouteIdsHashCode = 0;
    for (String multiPitchRouteId in multiPitchRouteIds) {
      if (multiPitchRouteIdsHashCode == 0) {
        multiPitchRouteIdsHashCode = multiPitchRouteId.hashCode;
      } else {
        multiPitchRouteIdsHashCode = multiPitchRouteIdsHashCode ^ multiPitchRouteId.hashCode;
      }
    }
    int coordinatesHashcode = 0;
    for (double coordinate in coordinates) {
      if (coordinatesHashcode == 0) {
        coordinatesHashcode = coordinatesHashcode.hashCode;
      } else {
        coordinatesHashcode = coordinatesHashcode ^ coordinate.hashCode;
      }
    }
    return
      mediaIdsHashCode ^
      singlePitchRouteIdsHashCode ^
      multiPitchRouteIdsHashCode ^
      comment.hashCode ^
      coordinatesHashcode ^
      distanceParking.hashCode ^
      distancePublicTransport.hashCode ^
      location.hashCode ^
      name.hashCode ^
      rating.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}