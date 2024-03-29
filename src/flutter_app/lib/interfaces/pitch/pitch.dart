import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';
import 'package:climbing_diary/interfaces/pitch/update_pitch.dart';

import '../grade.dart';

class Pitch extends MyBaseInterface{
  static const String boxName = 'pitches';
  static const String createBoxName = 'create_pitches';
  static const String deleteBoxName = 'delete_pitches';

  final List<String> ascentIds;
  final String comment;
  final Grade grade;
  final int length;
  final String name;
  final int num;
  final int rating;

  const Pitch({
    required super.updated,
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
      updated: json['updated'],
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
      updated: cache['updated'],
      ascentIds: cache['ascent_ids'] != null ? List<String>.from(cache['ascent_ids']) : [],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      grade: Grade.fromCache(cache['grade']),
      length: cache['length'],
      name: cache['name'],
      num: cache['num'],
      rating: cache['rating'],
    );
  }

  @override
  Map toJson() => {
    "updated": updated,
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

  @override
  int get hashCode {
    int mediaIdsHashCode = 0;
    for (String mediaId in mediaIds) {
      if (mediaIdsHashCode == 0) {
        mediaIdsHashCode = mediaId.hashCode;
      } else {
        mediaIdsHashCode = mediaIdsHashCode ^ mediaId.hashCode;
      }
    }
    int ascentIdsHashCode = 0;
    for (String ascentId in ascentIds) {
      if (ascentIdsHashCode == 0) {
        ascentIdsHashCode = ascentId.hashCode;
      } else {
        ascentIdsHashCode = ascentIdsHashCode ^ ascentId.hashCode;
      }
    }
    return
      mediaIdsHashCode ^
      ascentIdsHashCode ^
      comment.hashCode ^
      name.hashCode ^
      num.hashCode ^
      rating.hashCode ^
      length.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}