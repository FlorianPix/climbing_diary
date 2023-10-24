import 'package:climbing_diary/interfaces/route/update_route.dart';
import 'package:climbing_diary/interfaces/single_pitch_route/single_pitch_route.dart';

import '../grade.dart';

class UpdateSinglePitchRoute extends UpdateClimbingRoute{
  static const String boxName = 'edit_single_pitch_routes';

  List<String>? ascentIds;
  Grade? grade;
  int? length;

  UpdateSinglePitchRoute({
    this.ascentIds,
    super.mediaIds,
    required super.id,
    super.userId,
    super.comment,
    super.location,
    super.name,
    super.rating,
    this.grade,
    this.length
  });

  factory UpdateSinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return UpdateSinglePitchRoute(
      ascentIds: List<String>.from(json['ascent_ids']),
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

  factory UpdateSinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateSinglePitchRoute(
      ascentIds: cache['ascent_ids'] != null ? List<String>.from(cache['ascent_ids']) : [],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
      grade: cache['grade'] != null ? Grade.fromCache(cache['grade']) : null,
      length: cache['length'],
    );
  }

  SinglePitchRoute toSinglePitchRoute(SinglePitchRoute oldSinglePitchRoute){
    return SinglePitchRoute(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldSinglePitchRoute.mediaIds,
      id: id,
      userId: userId != null ? userId! : oldSinglePitchRoute.userId,
      comment: comment != null ? comment! : oldSinglePitchRoute.comment,
      name: name != null ? name! : oldSinglePitchRoute.name,
      rating: rating != null ? rating! : oldSinglePitchRoute.rating,
      location: location != null ? location! : oldSinglePitchRoute.location,
      ascentIds: ascentIds != null ? ascentIds! : oldSinglePitchRoute.ascentIds,
      grade: grade != null ? grade! : oldSinglePitchRoute.grade,
      length: length != null ? length! : oldSinglePitchRoute.length,
    );
  }

  @override
  Map toJson() => {
    "ascent_ids": ascentIds,
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
    "grade": grade?.toJson(),
    "length": length,
  };
}