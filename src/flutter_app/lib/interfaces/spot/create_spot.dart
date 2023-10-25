import 'package:climbing_diary/interfaces/spot/spot.dart';
import 'package:uuid/uuid.dart';

class CreateSpot {
  static const String boxName = 'create_spots';

  final String? comment;
  final List<double> coordinates;
  final int? distanceParking;
  final int? distancePublicTransport;
  final String location;
  final String name;
  final int rating;

  const CreateSpot({
    this.comment,
    required this.coordinates,
    required this.name,
    required this.location,
    required this.rating,
    this.distanceParking,
    this.distancePublicTransport,
  });

  factory CreateSpot.fromJson(Map<String, dynamic> json) {
    return CreateSpot(
      comment: json['comment'],
      coordinates: List<double>.from(json['coordinates']),
      distanceParking: json['distance_parking'],
      distancePublicTransport: json['distance_public_transport'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory CreateSpot.fromCache(Map<dynamic, dynamic> cache) {
    return CreateSpot(
      comment: cache['comment'],
      coordinates: List<double>.from(cache['coordinates']),
      location: cache['location'],
      distanceParking: cache['distance_parking'],
      distancePublicTransport: cache['distance_public_transport'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  Map toJson() => {
    "comment": comment,
    "coordinates": coordinates,
    "distance_parking": distanceParking,
    "distance_public_transport": distancePublicTransport,
    "location": location,
    "name": name,
    "rating": rating,
  };

  Spot toSpot(){
    return Spot(
      updated: DateTime.now().toIso8601String(),
      mediaIds: [],
      singlePitchRouteIds: [],
      multiPitchRouteIds: [],
      id: const Uuid().v4(),
      userId: '',
      comment: comment != null ? comment! : '',
      name: name,
      rating: rating,
      coordinates: coordinates,
      distanceParking: distanceParking != null ? distanceParking! : 0,
      distancePublicTransport: distancePublicTransport != null ? distancePublicTransport! : 0,
      location: location,
    );
  }

  @override
  int get hashCode {
    int coordinatesHashcode = 0;
    for (double coordinate in coordinates) {
      if (coordinatesHashcode == 0) {
        coordinatesHashcode = coordinatesHashcode.hashCode;
      } else {
        coordinatesHashcode = coordinatesHashcode ^ coordinate.hashCode;
      }
    }
    return
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