import 'package:climbing_diary/interfaces/single_pitch_route/update_single_pitch_route.dart';

class SinglePitchRoute {
  final List<String> mediaIds;
  final List<String> pitchIds;
  final String id;
  final String userId;

  final String comment;
  final String location;
  final String name;
  final int rating;
  final String grade;
  final int length;

  const SinglePitchRoute({
    required this.mediaIds,
    required this.pitchIds,
    required this.id,
    required this.userId,
    required this.comment,
    required this.location,
    required this.name,
    required this.rating,
    required this.grade,
    required this.length
  });

  factory SinglePitchRoute.fromJson(Map<String, dynamic> json) {
    return SinglePitchRoute(
      mediaIds: List<String>.from(json['media_ids']),
      pitchIds: List<String>.from(json['pitch_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      location: json['location'],
      name: json['name'],
      rating: json['rating'],
      grade: json['grade'],
      length: json['length'],
    );
  }

  factory SinglePitchRoute.fromCache(Map<dynamic, dynamic> cache) {
    return SinglePitchRoute(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      pitchIds: cache['pitch_ids'] != null ? List<String>.from(cache['pitch_ids']) : [],
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

  Map toJson() => {
    "media_ids": mediaIds,
    "pitch_ids": pitchIds,
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
      pitchIds: pitchIds,
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