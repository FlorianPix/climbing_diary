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
}