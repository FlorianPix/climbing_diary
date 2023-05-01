class UpdateSpot {
  List<String>? mediaIds;
  List<String>? routeIds;
  final String id;
  String? userId;
  String? comment;
  List<double>? coordinates;
  int? distanceParking;
  int? distancePublicTransport;
  String? location;
  String? name;
  int? rating;

  UpdateSpot({
    this.mediaIds,
    this.routeIds,
    required this.id,
    this.userId,
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

  factory UpdateSpot.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateSpot(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      routeIds: cache['route_ids'] != null ? List<String>.from(cache['route_ids']) : [],
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
}