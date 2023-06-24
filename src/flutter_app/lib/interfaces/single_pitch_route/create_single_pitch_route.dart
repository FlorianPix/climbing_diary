class CreateSinglePitchRoute {
  final String? comment;
  final String location;
  final String name;
  final int rating;
  final String grade;
  final int length;

  const CreateSinglePitchRoute({
    this.comment,
    required this.location,
    required this.name,
    required this.rating,
    required this.grade,
    required this.length
  });

  factory CreateSinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return CreateSinglePitchRoute(
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
      grade: json['grade'],
      length: json['length'],
    );
  }

  factory CreateSinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return CreateSinglePitchRoute(
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
      grade: cache['rating'],
      length: cache['rating'],
    );
  }

  Map toJson() => {
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
    "grade": grade,
    "length": length,
  };
}