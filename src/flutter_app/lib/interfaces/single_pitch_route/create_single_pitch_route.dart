import 'package:climbing_diary/interfaces/route/create_route.dart';

import '../grade.dart';

class CreateSinglePitchRoute extends CreateClimbingRoute {
  final Grade grade;
  final int length;

  const CreateSinglePitchRoute({
    super.comment,
    required super.location,
    required super.name,
    required super.rating,
    required this.grade,
    required this.length
  });

  factory CreateSinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return CreateSinglePitchRoute(
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
      grade: Grade.fromJson(json['grade']),
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

  @override
  Map toJson() => {
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
    "grade": grade.toJson(),
    "length": length,
  };
}