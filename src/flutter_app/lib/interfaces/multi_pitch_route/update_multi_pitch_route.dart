import 'package:climbing_diary/interfaces/route/update_route.dart';

import 'multi_pitch_route.dart';

class UpdateMultiPitchRoute extends UpdateClimbingRoute {
  static const String boxName = 'edit_multi_pitch_routes';
  List<String>? pitchIds;

  UpdateMultiPitchRoute({
    super.mediaIds,
    this.pitchIds,
    required super.id,
    super.userId,
    super.comment,
    super.location,
    super.name,
    super.rating,
  });

  factory UpdateMultiPitchRoute.fromJson(Map<String, dynamic> json) {
    return UpdateMultiPitchRoute(
      mediaIds: List<String>.from(json['media_ids']),
      pitchIds: List<String>.from(json['pitch_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
    );
  }

  factory UpdateMultiPitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateMultiPitchRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      pitchIds: cache['pitch_ids'] != null ? List<String>.from(cache['pitch_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      location: cache['location'],
      name: cache['name'],
      rating: cache['rating'],
    );
  }

  MultiPitchRoute toMultiPitchRoute(MultiPitchRoute oldMultiPitchRoute){
    return MultiPitchRoute(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldMultiPitchRoute.mediaIds,
      id: id,
      userId: userId != null ? userId! : oldMultiPitchRoute.userId,
      comment: comment != null ? comment! : oldMultiPitchRoute.comment,
      name: name != null ? name! : oldMultiPitchRoute.name,
      rating: rating != null ? rating! : oldMultiPitchRoute.rating,
      location: location != null ? location! : oldMultiPitchRoute.location,
      pitchIds: pitchIds != null ? pitchIds! : oldMultiPitchRoute.pitchIds,
    );
  }

  @override
  Map toJson() => {
    "media_ids": mediaIds,
    "pitch_ids": pitchIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
  };
}