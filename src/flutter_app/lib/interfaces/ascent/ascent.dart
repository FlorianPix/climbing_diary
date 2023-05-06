import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';

class Ascent {
  final List<String> mediaIds;
  final List<String> pitchIds;
  final String id;
  final String userId;

  final String comment;
  final String date;
  final String style;
  final int type;

  const Ascent({
    required this.mediaIds,
    required this.pitchIds,
    required this.id,
    required this.userId,
    required this.comment,
    required this.date,
    required this.style,
    required this.type,
  });

  factory Ascent.fromJson(Map<String, dynamic> json) {
    return Ascent(
      mediaIds: List<String>.from(json['media_ids']),
      pitchIds: List<String>.from(json['pitch_ids']),
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
      pitchIds: cache['pitch_ids'] != null ? List<String>.from(cache['pitch_ids']) : [],
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
    "pitch_ids": pitchIds,
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
      pitchIds: pitchIds,
      id: id,
      userId: userId,
      comment: comment,
      date: date,
      style: style,
      type: type,
    );
  }
}