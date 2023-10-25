import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';
import 'package:climbing_diary/interfaces/pitch/pitch.dart';

import '../grade.dart';

class UpdatePitch extends UpdateMyBaseInterface{
  static const String boxName = 'edit_pitches';

  List<String>? ascentIds;
  String? comment;
  Grade? grade;
  int? length;
  String? name;
  int? num;
  int? rating;

  UpdatePitch({
    super.mediaIds,
    this.ascentIds,
    required super.id,
    super.userId,
    this.comment,
    this.grade,
    this.length,
    this.name,
    this.num,
    this.rating,
  });

  factory UpdatePitch.fromJson(Map<String, dynamic> json) {
    return UpdatePitch(
      ascentIds: List<String>.from(json['ascent_ids']),
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      grade: json['grade'],
      length: json['length'],
      name: json['name'],
      num: json['num'],
      rating: json['rating'],
    );
  }

  factory UpdatePitch.fromCache(Map<dynamic, dynamic> cache) {
    return UpdatePitch(
      ascentIds: cache['ascent_ids'] != null ? List<String>.from(cache['ascent_ids']) : [],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      grade: cache['grade'],
      length: cache['length'],
      name: cache['name'],
      num: cache['cache'],
      rating: cache['rating'],
    );
  }

  Pitch toPitch(Pitch oldPitch){
    return Pitch(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldPitch.mediaIds,
      id: id,
      userId: userId != null ? userId! : oldPitch.userId,
      comment: comment != null ? comment! : oldPitch.comment,
      name: name != null ? name! : oldPitch.name,
      rating: rating != null ? rating! : oldPitch.rating,
      ascentIds: ascentIds != null ? ascentIds! : oldPitch.ascentIds,
      grade: grade != null ? grade! : oldPitch.grade,
      length: length != null ? length! : oldPitch.length,
      num: num != null ? num! : oldPitch.num,
    );
  }

  @override
  Map toJson() => {
    "ascent_ids": ascentIds,
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "grade": grade?.toJson(),
    "length": length,
    "name": name,
    "num": num,
    "rating": rating,
  };
}