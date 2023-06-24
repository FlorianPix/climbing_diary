import 'package:climbing_diary/interfaces/route/route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';

import '../grade.dart';

class SinglePitchRoute extends ClimbingRoute{
  final Grade grade;
  final int length;

  const SinglePitchRoute({
    required super.mediaIds,
    required super.id,
    required super.userId,
    required super.comment,
    required super.location,
    required super.name,
    required super.rating,
    required this.grade,
    required this.length
  });

  factory SinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return SinglePitchRoute(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
      grade: Grade.fromJson(json['grade']),
      length: json['length'],
    );
  }

  factory SinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return SinglePitchRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
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
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
    "grade": grade,
    "length": length,
  };

  UpdateSinglePitchRoute toUpdateSinglePitchRoute() {
    return UpdateSinglePitchRoute(
      mediaIds: mediaIds,
      id: id,
      userId: userId,
      comment: comment,
      location: location,
      name: name,
      rating: rating,
      grade: grade,
      length: length
    );
  }
}