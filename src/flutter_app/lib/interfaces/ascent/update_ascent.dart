import 'package:climbing_diary/interfaces/my_base_interface/update_my_base_interface.dart';

class UpdateAscent extends UpdateMyBaseInterface{
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