import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';
import 'package:climbing_diary/interfaces/spot/spot.dart';

class UpdateSpot extends UpdateMyBaseInterface{
  static const String boxName = 'edit_spots';

  List<String>? singlePitchRouteIds;
  List<String>? multiPitchRouteIds;
  String? comment;
  List<double>? coordinates;
  int? distanceParking;
  int? distancePublicTransport;
  String? location;
  String? name;
  int? rating;

  UpdateSpot({
    super.mediaIds,
    this.singlePitchRouteIds,
    this.multiPitchRouteIds,
    required super.id,
    super.userId,
    this.comment,
    this.coordinates,
    this.distanceParking,
    this.distancePublicTransport,
    this.location,
    this.name,
    this.rating,
  });

  factory UpdateSpot.fromJson(Map<String, dynamic> json) {
    return UpdateSpot(
      mediaIds: List<String>.from(json['media_ids']),
      singlePitchRouteIds: List<String>.from(json['single_pitch_route_ids']),
      multiPitchRouteIds: List<String>.from(json['single_pitch_route_ids']),
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

  factory UpdateSpot.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateSpot(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : null,
      singlePitchRouteIds: cache['single_pitch_route_ids'] != null ? List<String>.from(cache['single_pitch_route_ids']) : null,
      multiPitchRouteIds: cache['multi_pitch_route_ids'] != null ? List<String>.from(cache['multi_pitch_route_ids']) : null,
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      coordinates: cache['coordinates'] != null ? List<double>.from(cache['coordinates']) : null,
      distanceParking: cache['distance_parking'],
      distancePublicTransport: cache['distance_public_transport'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  Spot toSpot(Spot oldSpot){
    return Spot(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldSpot.mediaIds,
      id: id,
      userId: userId != null ? userId! : oldSpot.userId,
      comment: comment != null ? comment! : oldSpot.comment,
      name: name != null ? name! : oldSpot.name,
      rating: rating != null ? rating! : oldSpot.rating,
      singlePitchRouteIds: singlePitchRouteIds != null ? singlePitchRouteIds! : oldSpot.singlePitchRouteIds,
      multiPitchRouteIds: multiPitchRouteIds != null ? multiPitchRouteIds! : oldSpot.multiPitchRouteIds,
      coordinates: coordinates != null ? coordinates! : oldSpot.coordinates,
      distanceParking: distanceParking != null ? distanceParking! : oldSpot.distanceParking,
      distancePublicTransport: distancePublicTransport != null ? distancePublicTransport! : oldSpot.distancePublicTransport,
      location: location != null ? location! : oldSpot.location,
    );
  }

  @override
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
}