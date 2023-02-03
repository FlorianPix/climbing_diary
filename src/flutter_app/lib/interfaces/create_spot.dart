class CreateSpot {
  final String date;
  final String name;
  final List<double> coordinates;
  final List<String> location;
  final List<String>? routes;
  final int rating;
  final String? comment;
  final int? distanceParking;
  final int? distancePublicTransport;
  final List<String>? mediaIds;

  const CreateSpot({
    required this.date,
    required this.name,
    required this.coordinates,
    required this.location,
    this.routes,
    required this.rating,
    this.comment,
    this.distanceParking,
    this.distancePublicTransport,
    this.mediaIds
  });

  factory CreateSpot.fromJson(Map<String, dynamic> json) {
    return CreateSpot(
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

  factory CreateSpot.fromCache(Map<dynamic, dynamic> cache) {
    return CreateSpot(
        date: cache['date'],
        name: cache['name'],
        coordinates: List<double>.from(cache['coordinates']),
        location: List<String>.from(cache['location']),
        rating: cache['rating'],
        comment: cache['comment'],
        distanceParking: cache['distance_parking'],
        distancePublicTransport: cache['distance_public_transport'],
    );
  }

  Map toJson() => {
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