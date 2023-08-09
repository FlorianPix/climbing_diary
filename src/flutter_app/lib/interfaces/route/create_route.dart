class CreateClimbingRoute {
  final String? comment;
  final String? location;
  final String name;
  final int rating;

  const CreateClimbingRoute({
    this.comment,
    this.location,
    required this.name,
    required this.rating,
  });

  factory CreateClimbingRoute.fromJson(Map<String, dynamic> json) {
    return CreateClimbingRoute(
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory CreateClimbingRoute.fromCache(Map<dynamic, dynamic> cache) {
    return CreateClimbingRoute(
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  Map toJson() => {
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
  };

  @override
  int get hashCode {
    return
      comment.hashCode ^
      location.hashCode ^
      name.hashCode ^
      rating.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}