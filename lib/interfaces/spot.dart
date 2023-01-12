class Spot {
  final String id;
  final String date;
  final String name;
  final List<double> coordinates;
  final String country;
  final List<String> location;
  final List<String> routes;
  final int rating;
  final List<String> comments;
  final int familyFriendly;
  final int distanceParking;
  final int distancePublicTransport;

  const Spot({
    required this.id,
    required this.date,
    required this.name,
    required this.coordinates,
    required this.country,
    required this.location,
    required this.routes,
    required this.rating,
    required this.comments,
    required this.familyFriendly,
    required this.distanceParking,
    required this.distancePublicTransport
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['_id'],
      date: json['date'],
      name: json['name'],
      coordinates: List<double>.from(json['coordinates']),
      country: json['country'],
      location: List<String>.from(json['location']),
      routes: List<String>.from(json['routes']),
      rating: json['rating'],
      comments: List<String>.from(json['comments']),
      familyFriendly: json['family_friendly'],
      distanceParking: json['distance_parking'],
      distancePublicTransport: json['distance_public_transport']
    );
  }
}