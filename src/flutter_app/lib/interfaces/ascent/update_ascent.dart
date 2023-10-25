import 'package:climbing_diary/interfaces/ascent/ascent.dart';
import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';

class UpdateAscent extends UpdateMyBaseInterface{
  static const String boxName = 'edit_ascents';

  String? comment;
  String? date;
  int? style;
  int? type;

  UpdateAscent({
    super.mediaIds,
    required super.id,
    super.userId,
    this.comment,
    this.date,
    this.style,
    this.type,
  });

  factory UpdateAscent.fromJson(Map<String, dynamic> json) {
    return UpdateAscent(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id'],
      comment: json['comment'],
      date: json['date'],
      style: json['style'],
      type: json['type'],
    );
  }

  factory UpdateAscent.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateAscent(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id'],
      comment: cache['comment'],
      date: cache['date'],
      style: cache['style'],
      type: cache['type'],
    );
  }

  Ascent toAscent(Ascent oldAscent){
    return Ascent(
      updated: DateTime.now().toIso8601String(),
      mediaIds: mediaIds != null ? mediaIds! : oldAscent.mediaIds,
      id: id,
      userId: userId != null ? userId! : oldAscent.userId,
      comment: comment != null ? comment! : oldAscent.comment,
      date: date != null ? date! : oldAscent.date,
      style: style != null ? style! : oldAscent.style,
      type: type != null ? type! : oldAscent.type,
    );
  }

  @override
  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId,
    "comment": comment,
    "date": date,
    "style": style,
    "type": type,
  };
}