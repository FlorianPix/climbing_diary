class UpdateSpot {
  final String id;
  String? date;
  String? name;
  List<double>? coordinates;
  List<String>? location;
  List<String>? routes;
  int? rating;
  String? comment;
  int? distanceParking;
  int? distancePublicTransport;
  List<String>? mediaIds;

  UpdateSpot({
    required this.id,
    this.date,
    this.name,
    this.coordinates,
    this.location,
    this.routes,
    this.rating,
    this.comment,
    this.distanceParking,
    this.distancePublicTransport,
    this.mediaIds
  });

  factory UpdateSpot.fromJson(Map<String, dynamic> json) {
    return UpdateSpot(
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
}