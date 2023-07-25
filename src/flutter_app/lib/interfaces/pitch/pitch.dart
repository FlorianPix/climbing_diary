import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/pitch/update_pitch.dart';

import '../grade.dart';

class Pitch extends MyBaseInterface{
  final List<String> ascentIds;

  final String comment;
  final Grade grade;
  final int length;
  final String name;
  final int num;
  final int rating;

  const Pitch({
    required this.ascentIds,
    required super.mediaIds,
    required super.id,
    required super.userId,
    required this.comment,
    required this.grade,
    required this.length,
    required this.name,
    required this.num,
    required this.rating,
  });

  factory Pitch.fromJson(Map<String, dynamic> json) {
    return Pitch(
      ascentIds: List<String>.from(json['ascent_ids']),
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      grade: Grade.fromJson(json['grade']),
      length: json['length'],
      name: json['name'],
      num: json['num'],
      rating: json['rating'],
    );
  }

  factory Pitch.fromCache(Map<dynamic, dynamic> cache) {
    return Pitch(
      ascentIds: cache['ascent_ids'] != null ? List<String>.from(cache['ascent_ids']) : [],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      grade: cache['grade'],
      length: cache['length'],
      name: cache['name'],
      num: cache['num'],
      rating: cache['rating'],
    );
  }

  Map toJson() => {
    "ascent_ids": ascentIds,
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "grade": grade.toJson(),
    "length": length,
    "name": name,
    "num": num,
    "rating": rating,
  };

  UpdatePitch toUpdatePitch() {
    return UpdatePitch(
      ascentIds: ascentIds,
      mediaIds: mediaIds,
      id: id,
      userId: userId,
      comment: comment,
      grade: grade,
      length: length,
      name: name,
      num: num,
      rating: rating,
    );
  }
}