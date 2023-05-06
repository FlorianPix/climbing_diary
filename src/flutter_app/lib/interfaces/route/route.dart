import 'package:climbing_diary/interfaces/route/update_route.dart';

class ClimbingRoute {
  final List<String> mediaIds;
  final List<String> pitchIds;
  final String id;
  final String userId;

  final String comment;
  final String location;
  final String name;
  final int rating;

  const ClimbingRoute({
    required this.mediaIds,
    required this.pitchIds,
    required this.id,
    required this.userId,
    required this.comment,
    required this.location,
    required this.name,
    required this.rating,
  });

  factory ClimbingRoute.fromJson(Map<String, dynamic> json) {
    return ClimbingRoute(
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

  factory ClimbingRoute.fromCache(Map<dynamic, dynamic> cache) {
    return ClimbingRoute(
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

  UpdateClimbingRoute toUpdateClimbingRoute() {
    return UpdateClimbingRoute(
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