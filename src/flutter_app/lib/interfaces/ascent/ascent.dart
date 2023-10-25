import 'package:climbing_diary/interfaces/ascent/update_ascent.dart';
import 'package:climbing_diary/interfaces/my_base_interface/my_base_interface.dart';

class Ascent extends MyBaseInterface {
  static const String boxName = 'ascents';
  static const String createBoxName = 'create_ascents';
  static const String deleteBoxName = 'delete_ascents';

  final String comment;
  final String date;
  final int style;
  final int type;

  const Ascent({
    required super.updated,
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
      updated: json['updated'],
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
      updated: cache['updated'],
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      date: cache['date'],
      style: cache['style'],
      type: cache['type'],
    );
  }

  @override
  Map toJson() => {
    "updated": updated,
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
    return
      mediaIdsHashCode ^
      comment.hashCode ^
      date.hashCode ^
      style.hashCode ^
      type.hashCode;
  }

  @override
  bool operator ==(Object other){
    return hashCode == other.hashCode;
  }
}