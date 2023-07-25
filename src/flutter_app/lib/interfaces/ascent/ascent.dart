import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';

class Ascent extends MyBaseInterface {
  final String comment;
  final String date;
  final int style;
  final int type;

  const Ascent({
    required super.mediaIds,
    required super.id,
    required super.userId,
    required this.comment,
    required this.date,
    required this.style,
    required this.type,
  });

  factory Ascent.fromJson(Map<String, dynamic> json) {
    return Ascent(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      date: json['date'],
      style: json['style'],
      type: json['type'],
    );
  }

  factory Ascent.fromCache(Map<dynamic, dynamic> cache) {
    return Ascent(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      date: cache['date'],
      style: cache['style'],
      type: cache['type'],
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "date": date,
    "style": style,
    "type": type,
  };

  UpdateAscent toUpdateAscent() {
    return UpdateAscent(
      mediaIds: mediaIds,
      id: id,
      userId: userId,
      comment: comment,
      date: date,
      style: style,
      type: type,
    );
  }
}