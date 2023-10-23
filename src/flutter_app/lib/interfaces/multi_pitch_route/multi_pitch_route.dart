import 'package:climbing_diary/interfaces/multi_pitch_route/update_multi_pitch_route.dart';
import 'package:climbing_diary/interfaces/route/route.dart';

class MultiPitchRoute extends ClimbingRoute{
  static const String boxName = 'multi_pitch_routes';
  static const String createBoxName = 'create_multi_pitch_routes';
  static const String deleteBoxName = 'delete_multi_pitch_routes';
  final List<String> pitchIds;

  const MultiPitchRoute({
    required super.updated,
    required super.mediaIds,
    required this.pitchIds,
    required super.id,
    required super.userId,
    required super.comment,
    required super.location,
    required super.name,
    required super.rating,
  });

  factory MultiPitchRoute.fromJson(Map<String, dynamic> json) {
    return MultiPitchRoute(
      updated: json['updated'],
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

  factory MultiPitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return MultiPitchRoute(
      updated: cache['updated'],
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

  @override
  Map toJson() => {
    "updated": updated,
    "media_ids": mediaIds,
    "pitch_ids": pitchIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "location": location,
    "name": name,
    "rating": rating,
  };

  UpdateMultiPitchRoute toUpdateMultiPitchRoute() {
    return UpdateMultiPitchRoute(
      mediaIds: mediaIds,
      pitchIds: pitchIds,
      id: id,
      userId: userId,
      comment: comment,
      location: location,
      name: name,
      rating: rating,
    );
  }
}