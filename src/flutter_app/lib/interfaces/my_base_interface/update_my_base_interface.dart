class UpdateMyBaseInterface {
  List<String>? mediaIds;
  final String id;
  String? userId;

  UpdateMyBaseInterface({
    this.mediaIds,
    required this.id,
    this.userId
  });

  factory UpdateMyBaseInterface.fromJson(Map<String, dynamic> json) {
    return UpdateMyBaseInterface(
      mediaIds: List<String>.from(json['media_ids']),
      id: json['_id'],
      userId: json['user_id']
    );
  }

  factory UpdateMyBaseInterface.fromCache(Map<dynamic, dynamic> cache) {
    return UpdateMyBaseInterface(
      mediaIds: cache['media_ids'] != null ? List<String>.from(cache['media_ids']) : [],
      id: cache['_id'],
      userId: cache['user_id']
    );
  }

  Map toJson() => {
    "media_ids": mediaIds,
    "_id": id,
    "user_id": userId
  };
}