import 'package:climbing_diary/interfaces/route/create_route.dart';

import '../grade.dart';

class CreateSinglePitchRoute extends CreateClimbingRoute {
  static const String boxName = 'create_single_pitch_routes';

  final Grade grade;
  final int length;

  const CreateSinglePitchRoute({
    super.comment,
    required this.grade,
    required this.length,
    super.location,
    required super.name,
    required super.rating,
  });

  factory CreateSinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return CreateSinglePitchRoute(
      comment: json['comment'],
      grade: Grade.fromJson(json['grade']),
      length: json['length'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory CreateSinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return CreateSinglePitchRoute(
      comment: cache['comment'],
      grade: cache['rating'],
      length: cache['rating'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  @override
  Map toJson() => {
    "comment": comment,
    "grade": grade.toJson(),
    "length": length,
    "location": location,
    "name": name,
    "rating": rating
  };

  @override
  int get hashCode {
    return
      comment.hashCode ^
      grade.hashCode ^
      length.hashCode ^
      location.hashCode ^
      name.hashCode ^
      rating.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}