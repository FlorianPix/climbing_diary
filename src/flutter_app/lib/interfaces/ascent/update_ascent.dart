class UpdateAscent {
  List<String>? mediaIds;
  List<String>? pitchIds;
  final String id;
  String? userId;
  String? comment;
  String? date;
  String? style;
  int? type;

  UpdateAscent({
    this.mediaIds,
    this.pitchIds,
    required this.id,
    this.userId,
    this.comment,
    this.date,
    this.style,
    this.type,
  });

  factory UpdateAscent.fromJson(Map<String, dynamic> json) {
    return UpdateAscent(
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

  factory UpdateAscent.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateAscent(
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
}